class AddPasswordDigestToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :user_accounts, :password_digest, :string
  end
end
