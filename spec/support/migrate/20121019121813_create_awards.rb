class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.string  :name
      t.integer :author_id
    end
  end
end