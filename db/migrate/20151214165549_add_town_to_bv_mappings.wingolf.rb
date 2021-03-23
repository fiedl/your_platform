class AddTownToBvMappings < ActiveRecord::Migration[4.2]
  def change
    add_column :bv_mappings, :town, :string
  end
end
