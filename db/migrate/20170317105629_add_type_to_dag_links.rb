class AddTypeToDagLinks < ActiveRecord::Migration
  def change
    add_column :dag_links, :type, :string
  end
end
