module Distinctio
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      validates_with Distinctio::Validator

      class_attribute :_distinctio
      attr_accessor :distinctio_errors

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

      def distinctio_errors=(value)
        @distinctio_errors = value if value.is_a?(Enumerable)
      end

      def distinctio_errors
        @distinctio_errors || []
      end

    end

    module ClassMethods

      def distinctio(*attrs)
        self._distinctio = attrs
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
      opts = hash_keys.map { |e| e.keys.first.to_sym }.each_with_object({}) do |e, h|
        h[e] = :object
      end
      self.distinctio_errors = write_attributes!(Distinctio::Differs::Base.apply(attributes_are, delta, :object, opts))
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
        attrs = [] if attrs == :object
        make_snapshot[result, send(attr_name), attr_name, attrs] if respond_to?(attr_name)
      end
    end

    def write_attributes!(hsh)
      write_distinctio_attrs = lambda do |o, attrs|
        attrs.each_with_object({}) do |(attr_name, attr_value), errors|
          new_value = if attr_value.is_a?(Distinctio::Differs::Base::Error)
            errors[attr_name] = attr_value
            attr_value.value
          else
            attr_value
          end
          o.send("#{attr_name}=", new_value)
        end
      end

      write_attrs = lambda do |o, attrs|
        o.id = attrs[:id]
        if o.respond_to?(:write_attributes!)
          o.write_attributes!(attrs)
        else
          write_distinctio_attrs[o, attrs]
        end
      end

      assoc_errors = slice(hsh, hsh.keys - attributes.keys).each_with_object({}) do |(attr_name, attr_value), errors|
        association = send(attr_name)

        if association.is_a?(Enumerable) && attr_value.is_a?(Array)
          association.clear
          attr_value.map { |attrs| write_attrs[association.build, attrs] }.reject(&:empty?).tap do |ers|
            errors[attr_name] = ers unless ers.empty?
          end
        elsif attr_value.is_a?(Hash)
          errors[attr_name] = write_attrs[association, attr_value]
        elsif attr_value.nil?
          send "#{attr_name}=", nil
        end
      end

      self.distinctio_errors = assoc_errors.merge(write_distinctio_attrs[self, slice(hsh, attributes.keys)])
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
        attrs = [] if attrs == :object

        next unless hsh.has_key?(attr_name)
        branch = hsh[attr_name]

        result[attr_name] = if branch.is_a? Hash
          slice(branch, attrs)
        elsif branch.is_a? Enumerable || attrs.is_a?(Symbol)
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