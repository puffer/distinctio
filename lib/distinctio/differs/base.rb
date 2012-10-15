module Distinctio
  module Differs
    module Base
    module_function

      def calc(a, b, *mode_and_options)
        mode, options = extract_mode_and_options(mode_and_options)
        eval("Distinctio::Differs::#{camelize mode}").calc(a, b, options)
      end

      def apply a, delta, *mode_and_options
        mode, options = extract_mode_and_options(mode_and_options)
        eval("Distinctio::Differs::#{camelize mode}").apply(a, delta, options)
      end

      private
      module_function

      def extract_mode_and_options(mode_and_options)
        return mode_and_options.first || :simple,
          mode_and_options.last.is_a?(::Hash) ? mode_and_options.pop : {}
      end

      def self.camelize s
        s.to_s.split(/[^a-z0-9]/i).map{ |w| w.capitalize }.join
      end
    end
  end
end
