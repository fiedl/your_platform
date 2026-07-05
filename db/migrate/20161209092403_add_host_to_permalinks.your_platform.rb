# This migration comes from your_platform (originally 20161209080914)
class AddHostToPermalinks < ActiveRecord::Migration[4.2]
  def change
    add_column :permalinks, :host, :string
  end
end
