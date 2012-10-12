class Distinctio::Base
  def calc(a, b, *root_and_options)
    root, options = extract_root_and_options(root_and_options)

    if a == b
      {}
    elsif root == :text && [a, b].all?{ |s| s.is_a?(String) }
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_toText(dmp.patch_make(a, b)) }
    elsif root == :object && [a, b].all?{ |h| is_object_hash?(h) }
      a_id, b_id = a[:id] || a["id"], b[:id] || b["id"]

      return [a, b] if (a_id != nil) && a_id != b_id

      (a.keys | b.keys).each_with_object({}) do |key, hsh|
        next if (x = a[key]) == (y = b[key])

        current_option = (options && options[key.to_s]) || (options && options[key.to_sym]) || :simple

        hsh[key] = if current_option == :text && x.is_a?(String) && y.is_a?(String)
          calc(x, y, :text)
        else
          opts = options.each_with_object({}) do |(k, v), h|
            h[k.to_s.gsub("#{key.to_s}.", "")] = v if k.to_s.start_with? "#{key.to_s}."
          end
          calc(x, y, current_option, opts)
        end
      end
    elsif root == :object && [a, b].all?{ |h| array_of_hashes?(h) }
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

  def apply(a, delta, *root_and_options)
    root, options = extract_root_and_options(root_and_options)

    if delta.empty? || delta == nil
      a
    elsif root == :text && a.is_a?(String)
      DiffMatchPatch.new.tap { |dmp| return dmp.patch_apply(dmp.patch_fromText(delta), a).first }
    elsif root == :object && is_object_hash?(a)
      return apply(a, delta, root) if delta.is_a?(Array)

      delta.each_with_object(a.dup) do |(k, v), result|
        current_option = options[k.to_s] || options[k.to_sym] || :simple

        result[k] = if current_option == :text && result[k].is_a?(String)
          apply(result[k], v, :text)
        else
          opts = options.each_with_object({}) do |(ok, ov), h|
            h[ok.to_s.gsub("#{k.to_s}.", "")] = ov if ok.to_s.start_with? "#{k.to_s}."
          end
          apply(result[k], v, current_option, opts)
        end
      end.reject{ |k, v| v == nil }
    elsif root == :object && array_of_hashes?(a)
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

  def extract_root_and_options(root_and_options)
    return root_and_options.first || :simple,
    root_and_options.last.is_a?(::Hash) ? root_and_options.pop : {}
  end
end