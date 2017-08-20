class AddStreetToGeoLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_locations, :street, :string
    add_column :geo_locations, :state, :string
  end
end
