class CreateGeoInfos < ActiveRecord::Migration
  def change
    create_table :geo_infos do |t|

      t.float :longitude
      t.float :latitude

      t.integer :profile_field_id

      t.timestamps
    end
  end
end
