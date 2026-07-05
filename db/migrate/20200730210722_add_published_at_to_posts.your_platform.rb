# This migration comes from your_platform (originally 20200730210632)
class AddPublishedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published_at, :datetime
  end
end
