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
