# This migration comes from your_platform (originally 20120811140509)
class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.string :key
      t.integer :flagable_id
      t.string :flagable_type

      t.timestamps
    end
  end
end
