class AddTypeToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :type, :string
  end
end
