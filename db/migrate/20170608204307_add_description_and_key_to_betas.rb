class AddDescriptionAndKeyToBetas < ActiveRecord::Migration[4.2]
  def change
    add_column :betas, :description, :text
    add_column :betas, :key, :string
  end
end
