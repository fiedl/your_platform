class NotificationJob < ActiveJob::Base
  queue_as :notification
  
  def perform(*args)
    # Deliver all notifications that are due to be sent.
    Notification.due.deliver
  end
end