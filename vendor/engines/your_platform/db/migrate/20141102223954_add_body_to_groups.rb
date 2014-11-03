class AddBodyToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :body, :text
  end
end
