class AddTypeToDagLinks < ActiveRecord::Migration[4.2]
  def change
    add_column :dag_links, :type, :string
  end
end
