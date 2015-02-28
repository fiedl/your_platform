class AddInvalidToGeoLocation < ActiveRecord::Migration
  def change
    add_column :geo_locations, :invalid, :boolean
  end
end
