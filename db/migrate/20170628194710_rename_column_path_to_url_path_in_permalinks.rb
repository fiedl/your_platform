class RenameColumnPathToUrlPathInPermalinks < ActiveRecord::Migration[4.2]
  def change
    rename_column :permalinks, :path, :url_path
  end
end