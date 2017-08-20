# This migration comes from your_platform (originally 20120713102445)
class AddDeletedAtToDagLinks < ActiveRecord::Migration[4.2]
  def change
    add_column :dag_links, :deleted_at, :datetime
  end
end
