# This migration comes from your_platform (originally 20170203120149)
class CreateStates < ActiveRecord::Migration[4.2]
  def change
    create_table :states do |t|
      t.string :name
      t.integer :author_user_id
      t.integer :reference_id
      t.string :reference_type

      t.timestamps null: false
    end
  end
end
