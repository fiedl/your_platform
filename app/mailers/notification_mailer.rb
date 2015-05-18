class NotificationMailer < BaseMailer
  helper AvatarHelper
  helper MarkdownHelper
  
  def notification_email(recipient, notifications)
    locale = recipient.locale
    @notifications = notifications.order(:created_at)
    @user = recipient
    to_email = "#{recipient.title} <#{recipient.email}>"
    subject = I18n.t(:you_have_n_unread_notifications, n: notifications.count, locale: locale)
    mail to: to_email, subject: subject
  end

end