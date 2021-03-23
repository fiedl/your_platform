# This migration comes from your_platform (originally 20160618163115)
class CreateAuthTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :auth_tokens do |t|
      t.string :token
      t.integer :user_id
      t.string :resource_type
      t.integer :resource_id
      t.integer :post_id

      t.timestamps null: false
    end
    add_index :auth_tokens, :token, unique: true
  end
end
