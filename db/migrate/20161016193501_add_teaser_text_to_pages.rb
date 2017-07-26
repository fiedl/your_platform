class AddTeaserTextToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :teaser_text, :text
  end
end
