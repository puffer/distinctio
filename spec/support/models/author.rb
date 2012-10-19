class Author < ActiveRecord::Base
  include Distinctio::ActiveRecord

  has_and_belongs_to_many :books

  distinctio :id, :name, :bio, :books => [:id, :name, :year]
end