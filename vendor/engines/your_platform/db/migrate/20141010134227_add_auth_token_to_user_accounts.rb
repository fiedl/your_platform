class AddAuthTokenToUserAccounts < ActiveRecord::Migration
  def change
    add_column :user_accounts, :auth_token, :string
  end
end
