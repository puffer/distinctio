  class History < ActiveRecord::Base
    belongs_to :model, polymorphic: true
    serialize :delta, Hash
  end