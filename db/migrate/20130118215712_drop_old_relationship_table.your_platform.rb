class DropOldRelationshipTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :relationships
  end

  def down
    create_table :relationships do |t|
      t.string :name
      t.timestamps
    end
  end
end
