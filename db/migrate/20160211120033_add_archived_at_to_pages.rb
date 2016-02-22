class AddArchivedAtToPages < ActiveRecord::Migration
  def change
    add_column :pages, :archived_at, :datetime
  end
end
