class AddIncognitoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :incognito, :boolean
  end
end
