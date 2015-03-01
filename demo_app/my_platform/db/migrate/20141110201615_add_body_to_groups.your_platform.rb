# This migration comes from your_platform (originally 20141102223954)
class AddBodyToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :body, :text
  end
end
