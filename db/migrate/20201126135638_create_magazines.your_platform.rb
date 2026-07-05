# This migration comes from your_platform (originally 20201126134309)
class CreateMagazines < ActiveRecord::Migration[5.0]
  def change
    create_table :magazines do |t|
      t.string :name
      t.integer :group_id
      t.integer :editors_group_id
      t.integer :subscribers_group_id

      t.timestamps
    end
  end
end
