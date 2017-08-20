# This migration comes from your_platform (originally 20120701115059)
class AddPasswordDigestToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :user_accounts, :password_digest, :string
  end
end
