# This migration comes from your_platform (originally 20130315072759)
class AddInvalidToGeoLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_locations, :invalid, :boolean
  end
end
