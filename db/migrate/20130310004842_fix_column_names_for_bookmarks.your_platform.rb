# This migration comes from your_platform (originally 20130310004622)
class FixColumnNamesForBookmarks < ActiveRecord::Migration
  def change
    rename_column :bookmarks, :starrable_id, :bookmarkable_id
    rename_column :bookmarks, :starrable_type, :bookmarkable_type
  end
end
