class AddTypeToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :type, :string
  end
end
