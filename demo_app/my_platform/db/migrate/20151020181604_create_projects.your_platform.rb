# This migration comes from your_platform (originally 20151011125623)
class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
