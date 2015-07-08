# This migration comes from your_platform (originally 20150707223821)
class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sash_id, :integer
    add_column :users, :level,   :integer, :default => 0
  end
end
