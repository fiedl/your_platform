# This migration comes from your_platform (originally 20161011184334)
class AddTitleAndBodyToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :title, :string
    add_column :tags, :body, :text
  end
end
