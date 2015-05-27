class AddStreetToGeoLocations < ActiveRecord::Migration
  def change
    add_column :geo_locations, :street, :string
    add_column :geo_locations, :state, :string
  end
end
