class AddDeletedAtToDagLinks < ActiveRecord::Migration[4.2]
  def change
    add_column :dag_links, :deleted_at, :datetime
  end
end
