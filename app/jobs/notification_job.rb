class NotificationJob < ApplicationJob
  queue_as :notification

  def perform(*args)
    # # Deliver all notifications that are due to be sent.
    # Notification.due.deliver

    # 2015-05-28
    # For the moment, this job is deactivated.
    # We are experimenting with a rake task that runs `Notification.due.deliver`
    # every 60 seconds, because we had issues where notification emails were
    # delivered multiple times due to parallely processed jobs.
  end
end