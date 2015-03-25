# This migration comes from your_platform (originally 20120723165226)
class AddFemaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :female, :boolean
  end
end
