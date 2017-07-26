# This migration comes from your_platform (originally 20120427150156)
class AddGroupToken < ActiveRecord::Migration[4.2]
  def change
    change_table :groups do |t|
      t.string :token
      t.string :extensive_name
    end
  end
end
