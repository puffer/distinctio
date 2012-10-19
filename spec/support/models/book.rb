class Book < ActiveRecord::Base
  include Distinctio::ActiveRecord

  has_and_belongs_to_many :authors

  distinctio :id, :name, :year, 'authors' => [:id, :name, 'bio']
end