class AddEmbeddedToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :embedded, :boolean
  end
end
