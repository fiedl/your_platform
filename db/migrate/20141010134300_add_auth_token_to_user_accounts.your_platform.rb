# This migration comes from your_platform (originally 20141010134227)
class AddAuthTokenToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :user_accounts, :auth_token, :string
  end
end
