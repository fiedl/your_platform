class DropGeoInfos < ActiveRecord::Migration[4.2]
  def change
    drop_table :geo_infos
  end
end
