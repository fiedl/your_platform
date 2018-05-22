class NotificationMailerPreview < ActionMailer::Preview

  def notification_email
    recipient = User.first
    notifications = recipient.notifications.limit(10)
    NotificationMailer.notification_email(recipient, notifications)
  end

end