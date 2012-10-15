module Distinctio
  module Differs
    module Object
    module_function

      def calc a, b, options = {}
        if object_hash_array?(a) && object_hash_array?(b)
          #merge_object_hash_arrays(a, b).map do |(a, b)|
          #  Base.calc(a, b, :object, options)
          #end

          x, y = ary_2_hsh(a), ary_2_hsh(b)
          key = a.first.has_key?(:id) ? :id : "id"
          anti_key = (key == 'id') ? :id : "id"

          (x.keys | y.keys).map do |k|
            p = (x[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }
            r = (y[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }

            Base.calc(p, r, :object, options).merge({key => k})
          end.reject { |e| e.count == 1 }

        elsif object_hash?(a) && object_hash?(b)
          a_id, b_id = a[:id] || a["id"], b[:id] || b["id"]

          return [a, b] if (a_id != nil) && a_id != b_id

          (a.keys | b.keys).each_with_object({}) do |key, hsh|
            next if (x = a[key]) == (y = b[key])

            opts = options[key.to_sym]

            hsh[key] = if opts == :text && x.is_a?(String) && y.is_a?(String)
              Base.calc(x, y, :text)
            elsif opts == :object
              Base.calc(x, y, :object)
            elsif opts.is_a?(Hash)
              Base.calc(x, y, :object, opts)
            else
              Base.calc(x, y, :simple)
            end
          end
        else
          [a, b]
        end
      end

      def apply a, delta, options = {}
        if object_hash?(a)
          return Base.apply(a, delta, :simple) if delta.is_a?(Array)

          delta.each_with_object(a.dup) do |(k, v), result|
            opts = options[k.to_sym]

            result[k] = if opts == :text && result[k].is_a?(String)
              Base.apply(result[k], v, :text)
            elsif opts == :object
              Base.apply(result[k], v, :object)
            elsif opts.is_a?(Hash)
              Base.apply(result[k], v, :object, opts)
            else
              Base.apply(result[k], v, :simple)
            end
          end.reject{ |k, v| v == nil }
        elsif object_hash_array?(a)
          key = a.first.has_key?(:id) ? :id : "id"
          ary_2_hsh(a).tap do |entries|
            ary_2_hsh(delta).each do |k, v|
              entry = (entries[k] || {}).tap { |p| p.merge!({ key => k }) if p['id'] == nil }
              entries[k] = Base.apply(entry, v, :object, options)
            end
          end.values.reject { |e| e.count == 1 }
        end
      end

    private
    module_function

      def ary_2_hsh(ary)
        ary.each_with_object({}) do |e, hsh|
          key = e[e.has_key?(:id) ? :id : 'id']
          hsh[key] = e.reject { |k, v| [:id, 'id'].include? k }
        end
      end

      def object_hash_array? object
        object.is_a?(Array) && object.all? { |o| object_hash?(o) }
      end

      def object_hash? object
        object.is_a?(Hash) && (object.has_key?(:id) || object.has_key?("id"))
      end

=begin
      def merge_object_hash_arrays a, b, field = :id
        result = a.each_with_object({}) do |object, result|
          object = object.with_indifferent_access
          result[object[field]] = [object, nil]
        end

        result = b.each_with_object(result) do |object, result|
          object = object.with_indifferent_access
          result.key?(object[field]) ?
            result[object[field]][1] = object :
            result[object[field]] = [nil, object]
        end

        result.values
      end
=end
    end
  end
end
