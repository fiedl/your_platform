# This migration comes from your_platform (originally 20151120071606)
class AddAuthorIdToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :author_id, :integer
  end
end
