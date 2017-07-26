class CreateRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.string :ip
      t.string :method
      t.string :request_url
      t.string :referer
      t.integer :navable_id
      t.string :navable_type

      t.timestamps null: false
    end
  end
end
