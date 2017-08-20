# This migration comes from your_platform (originally 20120403002734)
class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string       :alias
      t.string       :email
      t.string       :password
      t.string       :first_name
      t.string       :last_name
      t.timestamps
    end
  end
end
