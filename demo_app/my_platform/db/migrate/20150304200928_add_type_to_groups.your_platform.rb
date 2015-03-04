# This migration comes from your_platform (originally 20150304192448)
class AddTypeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :type, :string
  end
end
