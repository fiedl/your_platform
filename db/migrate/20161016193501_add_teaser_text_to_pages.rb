class AddTeaserTextToPages < ActiveRecord::Migration
  def change
    add_column :pages, :teaser_text, :text
  end
end
