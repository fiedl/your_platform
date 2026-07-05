# This migration comes from your_platform (originally 20150518150459)
class AddReadAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :read_at, :datetime
  end
end
