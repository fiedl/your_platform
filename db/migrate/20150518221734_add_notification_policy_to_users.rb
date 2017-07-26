class AddNotificationPolicyToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :notification_policy, :string
  end
end
