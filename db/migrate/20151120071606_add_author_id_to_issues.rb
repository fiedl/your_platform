class AddAuthorIdToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :author_id, :integer
  end
end
