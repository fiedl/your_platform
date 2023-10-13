# This migration comes from your_platform (originally 20170628194710)
class RenameColumnPathToUrlPathInPermalinks < ActiveRecord::Migration[4.2]
  def change
    rename_column :permalinks, :path, :url_path
  end
end