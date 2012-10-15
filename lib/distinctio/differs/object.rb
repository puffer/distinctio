module Distinctio
  module Differs
    module Object
    module_function

      def calc a, b, options = {}
        if object_hash_array?(a) && object_hash_array?(b)
          key_name = a.first.has_key?(:id) ? :id : 'id'
          key_alias = key_name.is_a?(Symbol) ? key_name.to_sym : key_name.to_s

          a, b = ary_2_hsh(a), ary_2_hsh(b)

          (a.keys | b.keys).map do |id|
            x = (a[id] || {}).tap { |h| h.merge!({key_name => id}) if h[key_alias] == nil }
            y = (b[id] || {}).tap { |h| h.merge!({key_name => id}) if h[key_alias] == nil }
            calc_4_hashes(x, y, key_name, options).merge({key_name => id})
          end.reject { |attrs| attrs.count == 1 }

        elsif object_hash?(a) && object_hash?(b)
          key_name = a.has_key?(:id) ? :id : 'id'
          calc_4_hashes a, b, key_name, options
        end
      end

      def apply a, delta, options = {}
        if object_hash_array?(a)
          key_name = a.first.has_key?(:id) ? :id : 'id'

          ary_2_hsh(a).tap do |objects|
            ary_2_hsh(delta).each do |id, delta|
              attrs = (objects[id] || {}).tap do |attrs|
                unless attrs.has_key?('id') || attrs.has_key?(:id)
                  attrs.merge!({ key_name => id })
                end
              end

              objects[id] = apply(attrs, delta, options)
            end
          end.values.reject { |attrs| attrs.count == 1 }

        elsif object_hash?(a)
          apply_4_hash a, delta, options
        end
      end

    private
    module_function

      def calc_4_hashes(a, b, key_name, options={})
        a_id, b_id = a[key_name.to_sym] || a[key_name.to_s], b[key_name.to_sym] || b[key_name.to_s]

        return [a, b] if (a_id != nil) && a_id != b_id

        (a.keys | b.keys).each_with_object({}) do |attr, result|
          next if (x = a[attr]) == (y = b[attr])
          opts = options[attr.to_sym] || :simple
          opts = [:object, opts] if opts.is_a?(Hash)

          result[attr] = Base.calc x, y, *opts
        end
      end

      def apply_4_hash a, delta, options={}
        return Base.apply(a, delta, :simple) if delta.is_a?(Array)

        delta.each_with_object(a.dup) do |(attr, value), result|
          opts = options[attr.to_sym] || :simple
          opts = [:object, opts] if opts.is_a?(Hash)

          result[attr] = Base.apply(result[attr], value, *opts)
        end.reject { |attr, value| value == nil }
      end

      def ary_2_hsh(ary)
        ary.each_with_object({}) do |attrs, result|
          key = attrs[attrs.has_key?(:id) ? :id : 'id']
          result[key] = attrs.select { |attr, value| attr.to_s != 'id' }
        end
      end

      def object_hash_array? ary
        ary.is_a?(Array) && ary.all? { |object| object_hash?(object) }
      end

      def object_hash? object
        object.is_a?(Hash) && (object.has_key?(:id) || object.has_key?("id"))
      end
    end
  end
end
