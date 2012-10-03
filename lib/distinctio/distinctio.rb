require 'diff_match_patch'

class Distinctio::Base
  def calc(a, b, options={})
    return {} if (a == nil && b == nil) || (a != nil && a == b)

    if a.is_a?(String) && b.is_a?(String) && (options == :text)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_toText(dmp.patch_make(a, b)) }
    end

    if a.is_a?(Hash) && b.is_a?(Hash)
      (a.keys | b.keys).each_with_object({}) do |key, hsh|
        next if (x = a[key]) == (y = b[key])
        current_option = options[key.to_s] || options[key.to_sym] || :simple

        if current_option == :text && x.is_a?(String) && y.is_a?(String)
          :text
        elsif current_option == :object && array_of_hashes?(x) && array_of_hashes?(y)
          options.each_with_object({}) do |(k, v), h|
            h[k.to_s.gsub("#{key.to_s}.", "")] = v if k.to_s.start_with? "#{key.to_s}."
          end
        end.tap { |opts| hsh[key] = calc x, y, opts }
      end
    elsif array_of_hashes?(a) && array_of_hashes?(b)
      x, y = ary_2_hsh(a), ary_2_hsh(b)
      key = a.first.has_key?(:id) ? :id : "id"
      (x.keys | y.keys).map { |k| calc(x[k] || {}, y[k] || {}, options).merge key => k }.reject { |e| e.count == 1 }
    else
      [a, b]
    end
  end

  def apply(a, delta, options={})
    return a if delta.empty? || delta == nil

    if options == :text && a.is_a?(String)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_apply(dmp.patch_fromText(delta), a).first }
    elsif a.is_a?(Hash)
      delta.each_with_object(a.dup) do |(k, v), result|
        (result[k] = apply(result[k], v, options)).tap do |new_value|
          result.delete(k) if new_value == nil
        end
      end
    elsif array_of_hashes?(a)
      id_key_name = a.first.has_key?(:id) ? :id : "id"
      x, d = ary_2_hsh(a), ary_2_hsh(delta)

      d.each { |k, v| x[k] = apply(x[k] || {}, v, options) }
      x.map  { |k, v| v.merge id_key_name => k }.reject { |e| e.count == 1 }
    else
      a == delta.last ? delta.first : delta.last
    end
  end

  private

  def ary_2_hsh(ary)
    ary.each_with_object({}) do |e, hsh|
      key = e[e.has_key?(:id) ? :id : 'id']
      hsh[key] = e.reject { |k, v| [:id, 'id'].include? k }
    end
  end

  def array_of_hashes?(ary)
    ary.is_a?(Array) && ary.all? { |o| o.is_a?(Hash) && (o.has_key?(:id) || o.has_key?("id")) }
  end
end