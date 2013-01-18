class DropOldRelationshipTable < ActiveRecord::Migration
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
