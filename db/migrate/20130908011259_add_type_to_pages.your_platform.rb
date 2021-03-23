# This migration comes from your_platform (originally 20130908011215)
class AddTypeToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :type, :string
  end
end
