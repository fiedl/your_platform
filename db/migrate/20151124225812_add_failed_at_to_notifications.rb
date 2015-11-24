class AddFailedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :failed_at, :datetime
  end
end
