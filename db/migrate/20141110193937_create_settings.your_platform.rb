# This migration comes from your_platform (originally 20141110193830)
class CreateSettings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :thing_id, :null => true
      t.string :thing_type, :null => true
      t.timestamps
    end
    
    add_index :settings, [ :thing_type, :thing_id, :var ], :unique => true
  end

  def self.down
    drop_table :settings
  end
end
