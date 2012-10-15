class Distinctio
  module Differs
    module Simple
    module_function

      def calc a, b, options = {}
        a == b ? nil : [a, b]
      end

      def apply a, delta, options = {}
        if !delta
          a, nil
        elsif delta.first == a
          delta.second, nil
        else
          nil, [a, *delta]
        end
      end

    end
  end
end
