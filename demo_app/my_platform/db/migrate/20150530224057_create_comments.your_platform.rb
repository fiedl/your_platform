# This migration comes from your_platform (originally 20150530224025)
class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.text :text
      t.integer :author_user_id
      t.string :commentable_type
      t.integer :commentable_id

      t.timestamps null: false
    end
  end
end
