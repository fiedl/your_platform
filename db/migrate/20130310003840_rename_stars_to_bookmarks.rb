class RenameStarsToBookmarks < ActiveRecord::Migration[4.2]
  def up
    rename_table :stars, :bookmarks
  end

  def down
    rename_table :bookmarks_stars
  end
end
