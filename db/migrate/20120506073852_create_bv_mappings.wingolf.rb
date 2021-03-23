class CreateBvMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :bv_mappings do |t|
      t.string :bv_name
      t.string :plz

      t.timestamps
    end
  end
end
