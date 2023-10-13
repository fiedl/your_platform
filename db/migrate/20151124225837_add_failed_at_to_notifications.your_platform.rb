# This migration comes from your_platform (originally 20151124225812)
class AddFailedAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :failed_at, :datetime
  end
end
