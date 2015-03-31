# This migration comes from your_platform (originally 20130220184943)
class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.integer :starrable_id
      t.string :starrable_type
      t.integer :user_id

      t.timestamps
    end
  end
end
