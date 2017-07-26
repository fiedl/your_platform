class CreateLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :locations do |t|
      t.integer :object_id
      t.string :object_type
      t.float :longitude
      t.float :latitude

      t.timestamps null: false
    end
  end
end
