class AddInvalidToGeoLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_locations, :invalid, :boolean
  end
end
