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
      keys, hash_keys = extract_hash_keys(default_keys)
      opts = hash_keys.map { |e| e.keys.first.to_sym }.each_with_object({}) { |e, h| h[e] = :object }
      _apply Distinctio::Differs::Base.apply(attributes_are, delta, :object, opts)
    end

    def _apply(hsh)
      new_attrs = slice(hsh, attributes.keys)
      self.attributes = new_attrs

      slice(hsh, hsh.keys - attributes.keys).each do |attr_name, attr_value|
        association = self.send(attr_name)

        if association.is_a?(Enumerable) && attr_value.is_a?(Array)
          association.clear
          puts association.inspect
          puts attr_value.inspect
          attr_value.each { |attrs| association.build { |obj| write_attrs(obj, attrs) }; }

          puts association.inspect
          #puts attr_name
        elsif attr_value.is_a?(Hash)
          write_attrs(attr_value, attr_value)
        elsif attr_value.nil?
          send "#{attr_name}=", nil
        end
      end
    end

    def write_attrs o, attrs
      o.id = attrs[:id]
      if o.respond_to?(:_apply)
        o._apply attrs
      else
        o.attributes = attrs
      end
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