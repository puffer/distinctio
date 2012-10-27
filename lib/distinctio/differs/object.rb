module Distinctio
  module Differs
    module Object
    module_function

      def calc a, b, options = {}
        if object_hash_array?(a) && object_hash_array?(b)
          calc_4_arrays a, b, :id, options
        elsif object_hash?(a) && object_hash?(b)
          calc_4_hashes a.with_indifferent_access, b.with_indifferent_access, :id, options
        elsif object_hash?(a) && b.nil?
          [a, nil]
        elsif a.nil? && object_hash?(b)
          [nil, b]
        else
          raise ArgumentError, "a and b must be object attribute hashes or arrays of such hashes"
        end
      end

      def apply a, delta, options = {}
        if object_hash_array?(a) && object_hash_array?(delta)
          apply_2_arrays a, delta, :id, options
        elsif object_hash?(a) && (delta.is_a?(Hash) || delta.is_a?(Array))
          apply_2_hash(a, delta, options)
        elsif object_hash?(a)
          raise ArgumentError, "delta must be an object attribute hash or array of two elements"
        elsif object_hash_array?(a)
          raise ArgumentError, "delta must be an array of object attribute hashes"
        else
          raise ArgumentError, "a must be an object attribute hash, or an array of such hashes"
        end
      end

    private
    module_function

      def calc_4_arrays(a, b, key_name, options={})
        a, b = ary_2_hsh(a), ary_2_hsh(b)

        (a.keys | b.keys).map do |id|
          x = ensure_hash_contains_id(a[id], key_name, id)
          y = ensure_hash_contains_id(b[id], key_name, id)
          { key_name => id }.merge calc_4_hashes(x, y, key_name, options)
        end.reject { |attrs| attrs.count == 1 }
      end

      def ensure_hash_contains_id hsh, key_name, id
        (hsh || {}).with_indifferent_access.tap { |h| h[key_name] = id }
      end

      def calc_4_hashes(a, b, key_name, options={})
        if a[key_name].present? && a[key_name] != b[key_name]
          [a, b]
        else
          _calc_4_hashes(a, b, options)
        end
      end

      def _calc_4_hashes(a, b, options)
        (a.keys | b.keys).each_with_object({}) do |attr, result|
          x, y, opts = a[attr], b[attr], options[attr.to_sym]
          diff = _calc_4_hash_element(x, y, opts)
          result[attr] = diff if diff.present?
        end.with_indifferent_access
      end

      def _calc_4_hash_element x, y, opts=:simple
        return if x == y
        opts = [:object, opts] if opts.is_a?(Hash)
        Base.calc x, y, *opts
      end

      def apply_2_arrays a, delta, key_name, options
        objects = ary_2_hsh(a).each { |k, v| v[key_name] = k }

        ary_2_hsh(delta).each do |id, delta|
          attrs = (objects[id] || {}).with_indifferent_access
          attrs[key_name] = id
          objects[id] = apply_2_hash(attrs, delta, options)
        end

        remove_objects_with_no_column_attrs(objects, key_name)
      end

      def remove_objects_with_no_column_attrs(objects, key_name)
        objects.values.reject do |attrs|
          column_attrs = attrs.except(key_name)
          column_attrs.empty? || column_attrs.values.all?(&:nil?)
        end
      end

      def apply_2_hash a, delta, options={}
        return Base.apply(a, delta, :simple) if delta.is_a?(Array)

        delta.each_with_object(a.with_indifferent_access) do |(attr, value), result|
          opts = options[attr.to_sym] || :simple
          opts = [:object, opts] if opts.is_a?(Hash)
          result[attr] = Base.apply(result[attr], value, *opts)
        end.with_indifferent_access
      end

      def ary_2_hsh(ary)
        ary.each_with_object({}) do |attrs, result|
          attrs.with_indifferent_access.tap { |a| result[a[:id]] = a.except(:id) }
        end
      end

      def object_hash_array?(ary)
        ary.is_a?(Array) && ary.all? { |object| object_hash?(object) }
      end

      def object_hash?(object)
        object.is_a?(Hash) && object.with_indifferent_access.has_key?(:id)
      end
    end
  end
end
