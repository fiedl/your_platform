# This migration comes from your_platform (originally 20130314011638)
class DropGeoInfos < ActiveRecord::Migration[4.2]
  def change
    drop_table :geo_infos
  end
end
