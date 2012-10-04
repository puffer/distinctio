require 'diff_match_patch'

class Distinctio::Base
  def calc(a, b, options={})
    if (a == nil && b == nil) || (a != nil && a == b)
      {}
    elsif a.is_a?(String) && b.is_a?(String) && (options == :text)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_toText(dmp.patch_make(a, b)) }
    elsif a.is_a?(Hash) && b.is_a?(Hash) && is_object_hash?(a) && is_object_hash?(b) && options[:root] == :object
      a_id, b_id = a[:id] || a["id"], b[:id] || b["id"]

      return [a, b] if (a_id != nil) && a_id != b_id

      (a.keys | b.keys).each_with_object({}) do |key, hsh|
        next if (x = a[key]) == (y = b[key])

        current_option = (options && options[key.to_s]) || (options && options[key.to_sym]) || :simple

        opts = if current_option == :text && x.is_a?(String) && y.is_a?(String)
          :text
        else
          options.each_with_object({}) do |(k, v), h|
            h[k.to_s.gsub("#{key.to_s}.", "")] = v if k.to_s.start_with? "#{key.to_s}."
          end
        end
        opts.merge!({ :root => :object }) if current_option == :object

        hsh[key] = calc(x, y, opts)
      end
    elsif array_of_hashes?(a) && array_of_hashes?(b)
      x, y = ary_2_hsh(a), ary_2_hsh(b)
      key = a.first.has_key?(:id) ? :id : "id"
      anti_key = a.first.has_key?('id') ? :id : "id"

      (x.keys | y.keys).map do |k|
        p = (x[k] || {})
        p.merge! key => k if p[anti_key] == nil
        r = (y[k] || {})
        r.merge! key => k if r[anti_key] == nil
        calc(p, r, options)#.merge key => k
      end.reject { |e| e.count == 1 }
    else
      [a, b]
    end
  end

  def apply(a, delta, options={})
    if delta.empty? || delta == nil
      a
    elsif options == :text && a.is_a?(String)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_apply(dmp.patch_fromText(delta), a).first }
    elsif a.is_a?(Hash) && is_object_hash?(a) && options[:root] == :object
      if delta.is_a?(Array)
        return a == delta.last ? delta.first : delta.last
      end

      delta.each_with_object(a.dup) do |(k, v), result|
        current_option = options[k.to_s] || options[k.to_sym] || :simple

        opts = if current_option == :text && result[k].is_a?(String)
          :text
        else
          options.each_with_object({}) do |(ok, ov), h|
            h[ok.to_s.gsub("#{k.to_s}.", "")] = ov if ok.to_s.start_with? "#{k.to_s}."
          end
        end

        opts.merge!({ :root => :object }) if current_option == :object

        result.delete(k) if (result[k] = apply(result[k], v, opts)) == nil
      end
    elsif array_of_hashes?(a)
      id_key_name = a.first.has_key?(:id) ? :id : "id"
      x, d = ary_2_hsh(a), ary_2_hsh(delta)

      d.each do |k, v|
        p = (x[k] || {})
        p = p.merge! id_key_name => k if p['id'] == nil

        x[k] = apply(p, v, options)
      end
      x.map  { |k, v| v }.reject { |e| e.count == 1 }
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
    ary.is_a?(Array) && ary.all? { |o| o.is_a?(Hash) && is_object_hash?(o) }
  end

  def is_object_hash? hsh
    hsh.has_key?(:id) || hsh.has_key?("id")
  end
end