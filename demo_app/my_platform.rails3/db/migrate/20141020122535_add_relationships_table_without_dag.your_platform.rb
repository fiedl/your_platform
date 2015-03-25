# This migration comes from your_platform (originally 20130118220014)
class AddRelationshipsTableWithoutDag < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string :name
      t.integer :user1_id
      t.integer :user2_id
      t.timestamps
    end
  end
end
