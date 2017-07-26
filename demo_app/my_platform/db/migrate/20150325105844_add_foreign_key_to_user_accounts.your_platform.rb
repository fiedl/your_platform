# This migration comes from your_platform (originally 20120427044338)
class AddForeignKeyToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    change_table :user_accounts do |t|
      t.references :user
    end
  end
end
