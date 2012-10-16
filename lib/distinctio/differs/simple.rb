module Distinctio
  module Differs
    module Simple
    module_function

      def calc a, b, options = {}
        a == b ? {} : [a, b]
      end

      def apply a, delta, options = {}
        if delta.nil? || delta.empty?
          a
        elsif a == delta.last
          delta.first
        else
          delta.last
        end
      end

    end
  end
end
