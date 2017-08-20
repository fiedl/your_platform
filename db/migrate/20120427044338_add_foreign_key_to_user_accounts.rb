class AddForeignKeyToUserAccounts < ActiveRecord::Migration[4.2]
  def change
    change_table :user_accounts do |t|
      t.references :user
    end
  end
end
