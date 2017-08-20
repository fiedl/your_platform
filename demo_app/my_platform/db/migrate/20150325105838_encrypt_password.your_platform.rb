# This migration comes from your_platform (originally 20120405222050)
class EncryptPassword < ActiveRecord::Migration[4.2]

  def change
    rename_column :users, :password, :encrypted_password
    add_column :users, :salt, :string, :limit => 40
  end

end
