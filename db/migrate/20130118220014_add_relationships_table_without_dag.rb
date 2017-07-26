class AddRelationshipsTableWithoutDag < ActiveRecord::Migration[4.2]
  def change
    create_table :relationships do |t|
      t.string :name
      t.integer :user1_id
      t.integer :user2_id
      t.timestamps
    end
  end
end
