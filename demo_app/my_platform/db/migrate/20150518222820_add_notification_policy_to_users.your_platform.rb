# This migration comes from your_platform (originally 20150518221734)
class AddNotificationPolicyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_policy, :string
  end
end
