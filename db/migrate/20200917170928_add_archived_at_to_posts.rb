class AddArchivedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :archived_at, :datetime
  end
end
