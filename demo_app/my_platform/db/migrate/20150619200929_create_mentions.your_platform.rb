# This migration comes from your_platform (originally 20150619193355)
class CreateMentions < ActiveRecord::Migration[4.2]
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
