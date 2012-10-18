module Distinctio
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      class_attribute :_distinctio

      after_initialize do |record|
        @original = snapshot _distinctio
      end
    end

    def attributes_were(*attrs)
      slice @original, attrs.nil? || attrs.empty? ? default_keys : attrs
    end

    def attributes_are(*attrs)
      snapshot attrs.nil? || attrs.empty? ? default_keys : attrs
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

      hash_keys = keys.select { |k| k.is_a? Hash }
      keys = keys - hash_keys
      result = slice(hsh, keys)

      non_attr_keys = keys.map { |k| k.to_sym if k.respond_to? :to_sym } - result.keys.map(&:to_sym)

      result = non_attr_keys.each_with_object(result) do |k, result|
        if respond_to?(k)
          obj = send(k)

          result[k] = if obj.respond_to?(:snapshot)
            obj.snapshot
          elsif obj.is_a? Enumerable
            obj.each_with_object([]) do |o, ary|
              ary << o.snapshot if o.respond_to?(:snapshot)
            end
          end
        end
      end

      hash_keys.each_with_object(result) do |(k, v), result|
        if respond_to?(k)
          obj = send(k)
          result[k] = obj.snapshot(v) if obj.respond_to?(:snapshot)
        end
      end
    end

    private

    def slice hsh, keys
      return hsh if keys.nil? || keys.empty?

      keys.each_with_object(HashWithIndifferentAccess.new) do |k, result|
        result[k] = hsh[k] if hsh.has_key?(k)
      end
    end

    def default_keys
      _distinctio || []
    end
  end
end