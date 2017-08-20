class AddBodyToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :body, :text
  end
end
