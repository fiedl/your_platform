class RemoveSaltFromUserAccounts < ActiveRecord::Migration[4.2]
  def change
    remove_column :user_accounts, :salt, :encrypted_password
  end
end
