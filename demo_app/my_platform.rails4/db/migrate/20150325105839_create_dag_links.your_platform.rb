# This migration comes from your_platform (originally 20120425161138)
class CreateDagLinks < ActiveRecord::Migration
  def change
    create_table :dag_links do |t|
      t.integer :ancestor_id
      t.string :ancestor_type
      t.integer :descendant_id
      t.string :descendant_type
      t.boolean :direct
      t.integer :count

      t.timestamps
    end
  end
end
