class Distinctio
  module Differs
    module Text
    module_function

      def calc a, b, options = {}
        a == b ? nil : DiffMatchPatch.new.tap { |dmp| dmp.patch_toText(dmp.patch_make(a, b)) }
      end

      def apply a, delta, options = {}
        if !delta
          a, nil
        else
          patch = DiffMatchPatch.new.tap { |dmp| dmp.patch_apply(dmp.patch_fromText(delta), a) }
          patch.last.empty? ? (patch.first, nil) : *patch
        end
      end

    end
  end
end
