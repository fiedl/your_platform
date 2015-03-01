# This migration comes from your_platform (originally 20120710193308)
class RemoveSaltFromUserAccounts < ActiveRecord::Migration
  def change
    remove_column :user_accounts, :salt, :encrypted_password
  end
end
