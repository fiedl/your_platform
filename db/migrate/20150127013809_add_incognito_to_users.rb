class AddIncognitoToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :incognito, :boolean
  end
end
