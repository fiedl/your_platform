# This migration comes from your_platform (originally 20130310003840)
class RenameStarsToBookmarks < ActiveRecord::Migration
  def up
    rename_table :stars, :bookmarks
  end

  def down
    rename_table :bookmarks_stars
  end
end
