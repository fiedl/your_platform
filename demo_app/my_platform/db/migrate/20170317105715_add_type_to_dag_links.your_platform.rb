# This migration comes from your_platform (originally 20170317105629)
class AddTypeToDagLinks < ActiveRecord::Migration
  def change
    add_column :dag_links, :type, :string
  end
end
