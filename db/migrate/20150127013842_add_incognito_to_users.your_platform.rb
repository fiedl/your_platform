# This migration comes from your_platform (originally 20150127013809)
class AddIncognitoToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :incognito, :boolean
  end
end
