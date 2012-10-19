class Award < ActiveRecord::Base
  include Distinctio::ActiveRecord

  belongs_to :author
end