class AddDescriptionAndKeyToBetas < ActiveRecord::Migration
  def change
    add_column :betas, :description, :text
    add_column :betas, :key, :string
  end
end
