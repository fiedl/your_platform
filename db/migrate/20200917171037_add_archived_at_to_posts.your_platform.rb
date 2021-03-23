# This migration comes from your_platform (originally 20200917170928)
class AddArchivedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :archived_at, :datetime
  end
end
