# This migration comes from your_platform (originally 20151120071606)
class AddAuthorIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :author_id, :integer
  end
end
