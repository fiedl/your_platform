# This migration comes from your_platform (originally 20130320003051)
class AddRedirectToToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :redirect_to, :string
  end
end
