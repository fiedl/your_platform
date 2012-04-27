class CreateUserAccounts < ActiveRecord::Migration
  def change
    create_table :user_accounts do |t|
      t.string :encrypted_password
      t.string :salt, limit: 40
      t.timestamps
    end
    change_table :users do |t|
      t.remove :salt, :encrypted_password
    end
  end
end
