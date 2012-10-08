class Distinctio::Base
  def calc(a, b, options={})
    if a == b
      {}
    elsif options == :text && [a, b].all?{ |s| s.is_a?(String) }
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_toText(dmp.patch_make(a, b)) }
    elsif options[:root] == :object && [a, b].all?{ |h| is_object_hash?(h) }
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
        end.tap { |opts| opts.merge!({ :root => :object }) if current_option == :object }

        hsh[key] = calc(x, y, opts)
      end
    elsif options[:root] == :object && [a, b].all?{ |h| array_of_hashes?(h) }
      x, y = ary_2_hsh(a), ary_2_hsh(b)
      key = a.first.has_key?(:id) ? :id : "id"
      anti_key = (key == 'id') ? :id : "id"

      (x.keys | y.keys).map do |k|
        p = (x[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }
        r = (y[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }

        calc(p, r, options).merge({key => k})
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
    elsif options[:root] == :object && is_object_hash?(a)
      return apply(a, delta) if delta.is_a?(Array)

      delta.each_with_object(a.dup) do |(k, v), result|
        current_option = options[k.to_s] || options[k.to_sym] || :simple

        opts = if current_option == :text && result[k].is_a?(String)
          :text
        else
          options.each_with_object({}) do |(ok, ov), h|
            h[ok.to_s.gsub("#{k.to_s}.", "")] = ov if ok.to_s.start_with? "#{k.to_s}."
          end
        end.tap { |opts| opts.merge!({ :root => :object }) if current_option == :object }

        result[k] = apply(result[k], v, opts)
      end.reject{ |k, v| v == nil }
    elsif options[:root] == :object && array_of_hashes?(a)
      key = a.first.has_key?(:id) ? :id : "id"
      ary_2_hsh(a).tap do |entries|
        ary_2_hsh(delta).each do |k, v|
          entry = (entries[k] || {}).tap { |p| p.merge!({ key => k }) if p['id'] == nil }
          entries[k] = apply(entry, v, options)
        end
      end.values.reject { |e| e.count == 1 }
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

  def is_object_hash?(hsh)
    hsh.is_a?(Hash) && (hsh.has_key?(:id) || hsh.has_key?("id"))
  end
end