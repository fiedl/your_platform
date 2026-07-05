# This migration comes from your_platform (originally 20170713223928)
class AddPublishedAtToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :published_at, :datetime
  end
end
