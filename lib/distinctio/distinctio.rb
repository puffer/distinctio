class Distinctio::Base
  def calc(a, b, *mode_and_options)
    mode, options = extract_mode_and_options(mode_and_options)

    if a == b
      {}
    elsif mode == :text && [a, b].all?{ |s| s.is_a?(String) }
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_toText(dmp.patch_make(a, b)) }
    elsif mode == :object && [a, b].all?{ |h| is_object_hash?(h) }
      a_id, b_id = a[:id] || a["id"], b[:id] || b["id"]

      return [a, b] if (a_id != nil) && a_id != b_id

      (a.keys | b.keys).each_with_object({}) do |key, hsh|
        next if (x = a[key]) == (y = b[key])

        opts = options[key.to_sym]

        hsh[key] = if opts == :text && x.is_a?(String) && y.is_a?(String)
          calc(x, y, :text)
        elsif opts == :object
          calc(x, y, :object)
        elsif opts.is_a?(Hash)
          calc(x, y, :object, opts)
        else
          calc(x, y, :simple)
        end
      end
    elsif mode == :object && [a, b].all?{ |h| array_of_hashes?(h) }
      x, y = ary_2_hsh(a), ary_2_hsh(b)
      key = a.first.has_key?(:id) ? :id : "id"
      anti_key = (key == 'id') ? :id : "id"

      (x.keys | y.keys).map do |k|
        p = (x[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }
        r = (y[k] || {}).tap { |h| h.merge!({key => k}) if h[anti_key] == nil }

        calc(p, r, :object, options).merge({key => k})
      end.reject { |e| e.count == 1 }
    else
      [a, b]
    end
  end

  def apply(a, delta, *mode_and_options)
    mode, options = extract_mode_and_options(mode_and_options)

    if delta.empty? || delta == nil
      a
    elsif mode == :text && a.is_a?(String)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_apply(dmp.patch_fromText(delta), a).first }
    elsif mode == :object && is_object_hash?(a)
      return apply(a, delta, :simple) if delta.is_a?(Array)

      delta.each_with_object(a.dup) do |(k, v), result|
        opts = options[k.to_sym]

        result[k] = if opts == :text && result[k].is_a?(String)
          apply(result[k], v, :text)
        elsif opts == :object
          apply(result[k], v, :object)
        elsif opts.is_a?(Hash)
          apply(result[k], v, :object, opts)
        else
          apply(result[k], v, :simple)
        end
      end.reject{ |k, v| v == nil }
    elsif mode == :object && array_of_hashes?(a)
      key = a.first.has_key?(:id) ? :id : "id"
      ary_2_hsh(a).tap do |entries|
        ary_2_hsh(delta).each do |k, v|
          entry = (entries[k] || {}).tap { |p| p.merge!({ key => k }) if p['id'] == nil }
          entries[k] = apply(entry, v, :object, options)
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
    ary.is_a?(Array) && ary.all? { |o| is_object_hash?(o) }
  end

  def is_object_hash?(hsh)
    hsh.is_a?(Hash) && (hsh.has_key?(:id) || hsh.has_key?("id"))
  end

  def extract_mode_and_options(mode_and_options)
    return mode_and_options.first || :simple,
    mode_and_options.last.is_a?(::Hash) ? mode_and_options.pop : {}
  end
end