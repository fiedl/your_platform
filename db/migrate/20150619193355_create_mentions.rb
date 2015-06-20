class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :who_user_id
      t.integer :whom_user_id
      t.string :reference_type
      t.integer :reference_id

      t.timestamps null: false
    end
    
    add_index :mentions, :whom_user_id
  end
end
