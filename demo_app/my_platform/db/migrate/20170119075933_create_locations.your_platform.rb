# This migration comes from your_platform (originally 20170117231215)
class CreateLocations < ActiveRecord::Migration
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
