class AddPublishedAtToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :published_at, :datetime
  end
end
