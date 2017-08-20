class AddHostToPermalinks < ActiveRecord::Migration[4.2]
  def change
    add_column :permalinks, :host, :string
  end
end
