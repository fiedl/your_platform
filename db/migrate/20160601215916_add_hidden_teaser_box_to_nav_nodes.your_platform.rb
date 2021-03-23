# This migration comes from your_platform (originally 20160601212658)
class AddHiddenTeaserBoxToNavNodes < ActiveRecord::Migration[4.2]
  def change
    add_column :nav_nodes, :hidden_teaser_box, :boolean
  end
end
