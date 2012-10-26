module Distinctio
  module Differs
    module Base

      class Error
      end

    module_function

      def calc(a, b, *mode_and_options)
        mode, options = extract_mode_and_options(mode_and_options)
        find_subclass(mode).calc(a, b, options)
      end

      def apply a, delta, *mode_and_options
        mode, options = extract_mode_and_options(mode_and_options)
        find_subclass(mode).apply(a, delta, options)
      end

      private
      module_function

      def extract_mode_and_options(mode_and_options)
        return mode_and_options.first || :simple,
          mode_and_options.last.is_a?(::Hash) ? mode_and_options.pop : {}
      end

      def find_subclass mode
        eval("Distinctio::Differs::#{mode.to_s.camelize}")
      end
    end
  end
end
