class AddRedirectToToPage < ActiveRecord::Migration
  def change
    add_column :pages, :redirect_to, :string
  end
end
