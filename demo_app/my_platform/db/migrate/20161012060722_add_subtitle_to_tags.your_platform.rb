# This migration comes from your_platform (originally 20161012060259)
class AddSubtitleToTags < ActiveRecord::Migration
  def change
    add_column :tags, :subtitle, :string
  end
end
