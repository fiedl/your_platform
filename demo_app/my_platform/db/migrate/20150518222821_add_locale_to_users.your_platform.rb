# This migration comes from your_platform (originally 20150518221755)
class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :string
  end
end
