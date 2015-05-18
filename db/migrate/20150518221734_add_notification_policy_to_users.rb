class AddNotificationPolicyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_policy, :string
  end
end
