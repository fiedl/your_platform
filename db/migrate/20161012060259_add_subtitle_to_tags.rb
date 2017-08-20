class AddSubtitleToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :subtitle, :string
  end
end
