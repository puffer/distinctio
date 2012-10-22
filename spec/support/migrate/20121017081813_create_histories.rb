class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.string :model_type
      t.integer :model_id
      t.text :delta

      t.timestamps
    end
  end
end