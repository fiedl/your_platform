class RenameStarsToBookmarks < ActiveRecord::Migration
  def up
    rename_table :stars, :bookmarks
  end

  def down
    rename_table :bookmarks_stars
  end
end
