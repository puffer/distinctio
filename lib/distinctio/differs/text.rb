module Distinctio
  module Differs
    module Text
    module_function

      def calc a, b, options = {}
        if a == b
          nil
        else
          dmp = DiffMatchPatch.new
          dmp.patch_toText(dmp.patch_make(a, b))
        end
      end

      def apply a, delta, options = {}
        dmp = DiffMatchPatch.new
        dmp.patch_apply(dmp.patch_fromText(delta), a).first
      end

    end
  end
end
