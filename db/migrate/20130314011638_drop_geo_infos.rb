class DropGeoInfos < ActiveRecord::Migration
  def change
    drop_table :geo_infos
  end
end
