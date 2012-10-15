class Distinctio
  module Differs
    module Object
    module_function

      def calc a, b, options = {}
        if object_hash_array?(a) && object_hash_array?(b)
          merge_object_hash_arrays(a, b).map do |(a, b)|
            Base.calc(a, b, options)
          end
        elsif object_hash?(a) && object_hash?(b)
          
        else
          [a, b]
        end
      end

      def apply a, delta, options = {}

      end

    private

      def merge_object_hash_arrays a, b, field = :id
        result = a.inject({}) do |result, object|
          object = object.with_indifferent_access
          result[object[field]] = [object, nil]
          result
        end

        result = b.inject(result) do |result, object|
          object = object.with_indifferent_access
          result.key?(object[field]) ?
            result[object[field]][1] = object :
            result[object[field]] = [nil, object]
          result
        end

        result.values
      end

      def object_hash_array? object
        object.is_a?(Array) && object.all? { |o| object_hash?(o) }
      end

      def object_hash? object
        object.is_a?(Hash) && (object.has_key?(:id) || object.has_key?("id"))
      end

    end
  end
end
