class Club < ActiveRecord::Base
  include Distinctio::ActiveRecord

  has_many :authors
end