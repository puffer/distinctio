module Distinctio
  module Differs
    module Text

      class Error
        def result
          @options[:result]
        end

        def initialize options={}
          @options = options
        end
      end

    module_function

      def calc a, b, options = {}
        return nil if a == b

        diff = patcher.diff_main(a, b)
        patcher.diff_cleanupSemantic(diff)
        patch = patcher.patch_make(diff)
        patcher.patch_toText(patch)
      end

      def apply a, delta, options = {}
        result, statuses = patcher.patch_apply(patcher.patch_fromText(delta), a)
        has_patch_errors = statuses.any? { |status| !status }

        if has_patch_errors
          Error.new :result => result
        else
          result
        end
      end

    private
    module_function

      def patcher
        @patcher ||= DiffMatchPatch.new
      end

    end
  end
end
