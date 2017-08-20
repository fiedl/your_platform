class AddAuthTokenToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :user_accounts, :auth_token, :string
  end
end
