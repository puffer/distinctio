require 'diff_match_patch'

class Distinctio::Base
  attr_reader :method

  def initialize(options={})
    if options.delete(:method) == :text
      @method = :text
    else
      @method = :object
    end
  end

  # TODO: Strategies
  def calc(a, b, options={})
    if (a == nil && b == nil) || (a != nil && a == b)
      {}
    elsif a.is_a?(String) && b.is_a?(String) && (method == :text)
      patch = diff_match_path.patch_make(a, b)
      diff_match_path.patch_toText patch
    elsif a.is_a?(Hash) && b.is_a?(Hash)
      get_delta(a, b, options)
    elsif array_of_hashes?(a) && array_of_hashes?(b)
      x, y = ary_2_hsh(a), ary_2_hsh(b)
      id_key_name = a.first.has_key?(:id) ? :id : "id"

      (x.keys | y.keys).map do |k|
        get_delta(x[k], y[k], options).merge id_key_name => k
      end.reject { |e| e.count == 1 }
    else
      [a, b]
    end
  end

  # TODO: Strategies
  def apply(a, delta)
    if delta.empty?
      a
    elsif a.is_a?(Hash)
      apply_hash_delta(a, delta)
    elsif array_of_hashes?(a)
      x, d = ary_2_hsh(a), ary_2_hsh(delta)
      id_key_name = a.first.has_key?(:id) ? :id : "id"

      d.each { |k, v| x[k] = apply_hash_delta (x[k] || {}), v }
      x.map  { |k, v| v.merge id_key_name => k }.reject { |e| e.count == 1 }
    else

      if method == :text && a.is_a?(String)
        patch = diff_match_path.patch_fromText(delta)
        diff_match_path.patch_apply(patch, a).first
      else
        a == delta.last ? delta.first : delta.last
      end
    end
  end

  private

  def diff_match_path
    @diff_match_path ||= DiffMatchPatch.new
  end

  def get_delta(a, b, options={})
    c, d = a == nil ? {} : a, b == nil ? {} : b

    (c.keys | d.keys).each_with_object({}) do |key, hsh|
      x, y = c[key], d[key]

      current_option = options[key.to_s] || options[key.to_sym] || :simple

      if x != y
        if current_option == :text && x.is_a?(String) && y.is_a?(String)
          patch = diff_match_path.patch_make(x, y)
          hsh[key] = diff_match_path.patch_toText patch
        elsif current_option == :object && x.is_a?(Hash) && y.is_a?(Hash)
          hsh[key] = get_delta(x, y)

        elsif current_option == :object && array_of_hashes?(x) && array_of_hashes?(y)

          opts = options.each_with_object({}) do |(ok, ov), hsh|
            if ok.to_s.start_with? "#{key.to_s}."
              subkey = ok.to_s.gsub "#{key.to_s}.", ""
              hsh[subkey] = ov
            end
          end

          #TODO: Remove duplication
          p, k = ary_2_hsh(x), ary_2_hsh(y)
          id_key_name = x.first.has_key?(:id) ? :id : "id"

          hsh[key] = (p.keys | k.keys).map do |kk|
            get_delta(p[kk], k[kk], opts).merge id_key_name => kk
          end.reject { |e| e.count == 1 }
        else
          hsh[key] = [x, y]
        end
      end
    end
  end

  def ary_2_hsh(ary)
    ary.each_with_object({}) do |e, hsh|
      key = e[e.has_key?(:id) ? :id : 'id']
      hsh[key] = e.reject { |k, v| [:id, 'id'].include? k }
    end
  end

  def array_of_hashes?(ary)
    ary.is_a?(Array) && ary.all? { |o| o.is_a?(Hash) && (o.has_key?(:id) || o.has_key?("id")) }
  end

  def apply_hash_delta(hsh, delta)
    hsh.dup.tap do |result|
      delta.each do |k, v|
        if method == :text && result[k].is_a?(String)
          patch = diff_match_path.patch_fromText(v)
          result[k] = diff_match_path.patch_apply(patch, result[k]).first
        else
          x, y = v.first, v.last
          (result[k] == x ? y : x).tap do |new_value|
            if new_value != nil
              result[k] = new_value
            else
              result.delete(k)
            end
          end
        end
      end
    end
  end
end