class Author < ActiveRecord::Base
  include Distinctio::ActiveRecord

  has_and_belongs_to_many :books

  distinctio :id, :nonexisting_field, :name, 'bio', :books => [:id, 'name', :year, :nonexisting_field]
end