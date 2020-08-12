class AddPublishedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published_at, :datetime
  end
end
