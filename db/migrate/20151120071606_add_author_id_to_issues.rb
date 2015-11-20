class AddAuthorIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :author_id, :integer
  end
end
