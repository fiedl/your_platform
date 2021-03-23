# This migration comes from your_platform (originally 20171216190916)
class AddLocaleToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :locale, :string
  end
end
