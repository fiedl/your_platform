# This migration comes from your_platform (originally 20141010134227)
class AddAuthTokenToUserAccounts < ActiveRecord::Migration
  def change
    add_column :user_accounts, :auth_token, :string
  end
end
