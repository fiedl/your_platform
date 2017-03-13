# This migration comes from your_platform (originally 20170312093857)
class AddGroupIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :group_id, :integer
  end
end
