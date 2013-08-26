class AddForeignKeyToUserAccounts < ActiveRecord::Migration
  def change
    change_table :user_accounts do |t|
      t.references :user
    end
  end
end
