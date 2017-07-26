class AddGroupIdToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :group_id, :integer
  end
end
