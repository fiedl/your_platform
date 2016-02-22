# This migration comes from your_platform (originally 20160211120033)
class AddArchivedAtToPages < ActiveRecord::Migration
  def change
    add_column :pages, :archived_at, :datetime
  end
end
