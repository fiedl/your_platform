class CreatePostDeliveries < ActiveRecord::Migration[4.2]
  def change
    create_table :post_deliveries do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :user_email
      t.datetime :sent_at
      t.datetime :failed_at
      t.string :comment

      t.timestamps null: false
    end
  end
end
