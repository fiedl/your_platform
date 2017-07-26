class AddRedirectToToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :redirect_to, :string
  end
end
