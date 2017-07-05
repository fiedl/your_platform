class RenameColumnPathToUrlPathInPermalinks < ActiveRecord::Migration
  def change
    rename_column :permalinks, :path, :url_path
  end
end