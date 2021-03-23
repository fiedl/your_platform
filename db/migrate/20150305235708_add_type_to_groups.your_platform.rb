# This migration comes from your_platform (originally 20150304192448)
class AddTypeToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :type, :string
  end
end
