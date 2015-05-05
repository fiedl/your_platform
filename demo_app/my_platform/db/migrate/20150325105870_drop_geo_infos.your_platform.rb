# This migration comes from your_platform (originally 20130314011638)
class DropGeoInfos < ActiveRecord::Migration
  def change
    drop_table :geo_infos
  end
end
