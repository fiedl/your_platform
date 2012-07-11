class RemoveSaltFromUserAccounts < ActiveRecord::Migration
  def change
    remove_column :user_accounts, :salt, :encrypted_password
  end
end
