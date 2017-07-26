class AddFailedAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :failed_at, :datetime
  end
end
