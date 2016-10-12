class AddSubtitleToTags < ActiveRecord::Migration
  def change
    add_column :tags, :subtitle, :string
  end
end
