# This migration comes from your_platform (originally 20170608204307)
class AddDescriptionAndKeyToBetas < ActiveRecord::Migration[4.2]
  def change
    add_column :betas, :description, :text
    add_column :betas, :key, :string
  end
end
