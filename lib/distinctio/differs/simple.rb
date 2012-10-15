module Distinctio
  module Differs
    module Simple
    module_function

      def calc a, b, options = {}
        a == b ? {} : [a, b]
      end

      def apply a, delta, options = {}
        return a if delta == nil || delta.empty?
        a == delta.last ? delta.first : delta.last
      end

    end
  end
end
