module Distinctio
  module Differs
    module Simple
    module_function

      def calc a, b, options = {}
        a == b ? {} : [a, b]
      end

      def apply a, delta, options = {}
        if delta.empty? || delta == nil
          return a#, nil
        else
          a == delta.last ? delta.first : delta.last
        #else
        #  return a#, [a, *delta]
        end
      end

    end
  end
end
