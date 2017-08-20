class AddHiddenTeaserBoxToNavNodes < ActiveRecord::Migration[4.2]
  def change
    add_column :nav_nodes, :hidden_teaser_box, :boolean
  end
end
