class AddHostToPermalinks < ActiveRecord::Migration
  def change
    add_column :permalinks, :host, :string
  end
end
