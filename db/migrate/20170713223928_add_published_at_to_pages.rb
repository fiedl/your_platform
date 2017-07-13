class AddPublishedAtToPages < ActiveRecord::Migration
  def change
    add_column :pages, :published_at, :datetime
  end
end
