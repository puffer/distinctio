module Distinctio
  class Validator < ::ActiveModel::Validator
    def validate(record)
      if record.respond_to?(:distinctio_errors) && record.distinctio_errors.any?
        record.errors[:distinctio_errors] = "Errors occured while applying diff."
      end
    end
  end
end