class AddDeletedAtToDagLinks < ActiveRecord::Migration
  def change
    add_column :dag_links, :deleted_at, :datetime
  end
end
