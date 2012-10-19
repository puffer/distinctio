class Author < ActiveRecord::Base
  include Distinctio::ActiveRecord

  belongs_to :club
  has_many :awards
  has_and_belongs_to_many :books

  distinctio :id, :nonexisting_field, :name, 'bio', :club,
    { :awards => [:id, :name] }, {:books => [:id, 'name', :year, :nonexisting_field]}
end