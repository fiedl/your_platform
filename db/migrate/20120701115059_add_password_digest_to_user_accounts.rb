class AddPasswordDigestToUserAccounts < ActiveRecord::Migration
  def change
    add_column :user_accounts, :password_digest, :string
  end
end
