class AddLocaleToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :locale, :string
  end
end
