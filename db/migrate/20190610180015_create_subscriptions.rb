class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.integer :group_id
      t.string :type

      t.timestamps
    end
  end
end
