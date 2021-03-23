class CreateRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :relationships do |t|
      t.string :name

      t.timestamps
    end
  end
end
