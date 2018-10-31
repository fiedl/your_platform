class DeviseTokenAuthCreateUserAccounts < ActiveRecord::Migration[5.0]

  def change
    add_column :user_accounts, :tokens, :text
    add_column :user_accounts, :provider, :text
    add_column :user_accounts, :uid, :text
  end

end
