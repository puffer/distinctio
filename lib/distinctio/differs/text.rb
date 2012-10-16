module Distinctio
  module Differs
    module Text

      class Error
        attr_reader :a, :delta

        def initialize a, delta
          @a, @delta = a, delta
        end
      end

    module_function

      def calc a, b, options = {}
        raise ArgumentError, "a must be string" unless a.is_a?(String)
        raise ArgumentError, "b must be string" unless b.is_a?(String)

        return nil if a == b

        diff = patcher.diff_main(a, b)
        patcher.diff_cleanupSemantic(diff)
        patch = patcher.patch_make(diff)
        patcher.patch_toText(patch)
      end

      def apply a, delta, options = {}
        raise ArgumentError, "a must be string" unless a.is_a?(String)
        raise ArgumentError, "delta must be string" unless delta.is_a?(String)

        result, statuses = patcher.patch_apply(patcher.patch_fromText(delta), a)
        has_patch_errors = statuses.any? { |status| !status }
        has_patch_errors ? Error.new(a, delta) : result
      end

    private
    module_function

      def patcher
        @patcher ||= DiffMatchPatch.new
      end

    end
  end
end
