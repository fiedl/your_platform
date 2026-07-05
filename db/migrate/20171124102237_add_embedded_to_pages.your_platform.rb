# This migration comes from your_platform (originally 20171124102130)
class AddEmbeddedToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :embedded, :boolean
  end
end
