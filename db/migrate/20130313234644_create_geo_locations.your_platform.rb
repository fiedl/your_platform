# This migration comes from your_platform (originally 20130313234131)
class CreateGeoLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :geo_locations do |t|
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :country
      t.string :country_code
      t.string :city
      t.string :postal_code

      t.timestamps
    end
    add_index :geo_locations, :address
  end
end
