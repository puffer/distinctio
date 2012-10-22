module Distinctio
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      class_attribute :_distinctio

      after_initialize do |record|
        @original = snapshot(_distinctio)
      end

      after_create do |record|
        @original = snapshot(_distinctio)
      end

      after_update do |record|
        @original = snapshot(_distinctio)
        History.create(model_type: record.class.name, model_id: record.id, delta: @original)
      end
    end

    def attributes_were(*attrs)
      slice(@original, attrs.nil? || attrs.empty? ? default_keys : attrs)
    end

    def attributes_are(*attrs)
      snapshot(attrs.nil? || attrs.empty? ? default_keys : attrs)
    end

    def apply(delta)
      new_state = Distinctio::Differs::Base.apply(attributes_are, delta, :object, { :authors => :object })

      attr_delta = slice(new_state, attributes.keys)
      other_attrs = slice(new_state, new_state.keys - attr_delta.keys)

      other_attrs.each do |key, value|
        attr = self.send(key)

        if attr.is_a?(Enumerable)
          attr.clear
          value.each { |v| attr.build v }
        end
      end

      self.attributes = attr_delta
    end

    module ClassMethods

      def distinctio(*attrs)
        self._distinctio = attrs
      end

    end

    def snapshot keys=[]
      hsh = attributes.with_indifferent_access

      keys = default_keys if keys.nil?
      return hsh if keys.empty?

      keys, hash_keys = extract_hash_keys(keys)
      result = slice(hsh, keys)

      non_attr_keys = keys.map { |k| k.to_sym if k.respond_to? :to_sym } - result.keys.map(&:to_sym)

      make_snapshot = lambda do |result, obj, attr_name, attrs|
        result[attr_name] = if obj.respond_to?(:snapshot)
          obj.snapshot(attrs)
        elsif obj.is_a? Enumerable
          obj.each_with_object([]) do |o, ary|
            ary << o.snapshot(attrs) if o.respond_to?(:snapshot)
          end
        end
      end

      result = non_attr_keys.each_with_object(result) do |attr_name, result|
        make_snapshot[result, send(attr_name), attr_name, []] if respond_to?(attr_name)
      end

      hash_keys.each_with_object(result) do |pair, result|
        attr_name, attrs = pair.first
        make_snapshot[result, send(attr_name), attr_name, attrs] if respond_to?(attr_name)
      end
    end

    private

    def extract_hash_keys ary
      hash_keys = ary.select { |k| k.is_a? Hash }
      return ary - hash_keys, hash_keys
    end

    def slice hsh, keys
      return hsh if keys.nil? || keys.empty?

      keys, hash_keys = extract_hash_keys(keys)

      result = keys.each_with_object({}.with_indifferent_access) do |k, result|
        result[k] = hsh[k] if hsh.has_key?(k)
      end

      hash_keys.each_with_object(result) do |pair, result|
        (attr_name, attrs) = pair.first

        next unless hsh.has_key?(attr_name)
        branch = hsh[attr_name]

        result[attr_name] = if branch.is_a? Hash
          slice(branch, attrs)
        elsif branch.is_a? Enumerable
          branch.each_with_object([]) do |h, ary|
            ary << slice(h, attrs) if h.is_a?(Hash)
          end
        end
      end
    end

    def default_keys
      _distinctio || []
    end
  end
end