module Distinctio
  module Differs
    module Simple

      class Error < Distinctio::Differs::Base::Error
        attr_reader :actual_a, :expected_a, :expected_b

        def initialize actual_a, expected_a, expected_b
          @actual_a, @expected_a, @expected_b = actual_a, expected_a, expected_b
        end

        def value
          expected_b
        end
      end

    module_function

      def calc a, b, options = {}
        a == b ? nil : [a, b]
      end

      def apply a, delta, options = {}
        if delta.present? && !(delta.is_a?(Array) && delta.count == 2)
          raise ArgumentError, "delta must be nil, or an Array, containing two elements"
        end

        if delta.nil?
          a
        elsif a == delta.last
          delta.first
        elsif a == delta.first
          delta.last
        else
          Error.new a, delta.first, delta.second
        end
      end

    end
  end
end
