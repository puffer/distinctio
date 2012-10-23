module Distinctio
  class Nothing
    def == other
      eql? other
    end

    def eql? other
      other.is_a? Distinctio::Nothing
    end
  end
end