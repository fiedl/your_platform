class AddGroupToken < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.string :token
      t.string :extensive_name
    end
  end
end
