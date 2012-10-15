class Distinctio::Base
  def calc(a, b, *mode_and_options)
    mode, options = extract_mode_and_options(mode_and_options)
    Distinctio::Differs::Base.calc(a, b, mode, options)
  end

  def apply(a, delta, *mode_and_options)
    mode, options = extract_mode_and_options(mode_and_options)
    Distinctio::Differs::Base.apply(a, delta, mode, options)
  end

  private

  def extract_mode_and_options(mode_and_options)
    return mode_and_options.first || :simple,
    mode_and_options.last.is_a?(::Hash) ? mode_and_options.pop : {}
  end

end