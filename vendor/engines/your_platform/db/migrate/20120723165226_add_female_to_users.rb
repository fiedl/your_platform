class AddFemaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :female, :boolean
  end
end
