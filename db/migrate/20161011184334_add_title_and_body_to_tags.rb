class AddTitleAndBodyToTags < ActiveRecord::Migration
  def change
    add_column :tags, :title, :string
    add_column :tags, :body, :text
  end
end
