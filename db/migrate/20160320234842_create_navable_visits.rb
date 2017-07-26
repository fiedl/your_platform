class CreateNavableVisits < ActiveRecord::Migration[4.2]
  def change
    create_table :navable_visits do |t|
      t.integer :navable_id
      t.string :navable_type
      t.integer :group_id

      t.timestamps null: false
    end
  end
end
