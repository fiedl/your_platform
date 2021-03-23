class CreateWorkflows < ActiveRecord::Migration[4.2]
  def change
    create_table :workflows do |t|
      t.string :name

      t.timestamps
    end
  end
end
