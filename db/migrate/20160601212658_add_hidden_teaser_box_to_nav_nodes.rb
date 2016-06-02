class AddHiddenTeaserBoxToNavNodes < ActiveRecord::Migration
  def change
    add_column :nav_nodes, :hidden_teaser_box, :boolean
  end
end
