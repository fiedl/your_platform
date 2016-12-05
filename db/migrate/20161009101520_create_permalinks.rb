class CreatePermalinks < ActiveRecord::Migration
  def change
    create_table :permalinks do |t|
      t.string :path
      t.string :reference_type
      t.integer :reference_id

      t.timestamps null: false
    end
  end
end
