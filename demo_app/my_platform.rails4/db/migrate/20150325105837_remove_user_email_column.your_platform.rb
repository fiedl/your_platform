# This migration comes from your_platform (originally 20120403161549)
class RemoveUserEmailColumn < ActiveRecord::Migration
  def change
    remove_column :users, :email
  end
end
