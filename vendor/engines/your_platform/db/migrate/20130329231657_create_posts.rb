class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :subject
      t.text :text
      t.integer :group_id
      t.integer :author_user_id
      t.string :external_author
      t.datetime :sent_at
      t.boolean :sticky

      t.timestamps
    end
  end
end
