# This migration comes from your_platform (originally 20150518134530)
class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :author_id
      t.string :reference_url
      t.string :reference_type
      t.integer :reference_id
      t.string :message
      t.text :text
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end
