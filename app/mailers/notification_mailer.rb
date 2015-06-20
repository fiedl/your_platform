class NotificationMailer < BaseMailer
  helper AvatarHelper
  helper MarkdownHelper
  helper MarkupHelper
  helper EmojiHelper
  helper QuickLinkHelper
  helper MentionsHelper
  
  def notification_email(recipient, notifications)
    locale = recipient.locale
    @notifications = notifications.order('created_at desc')
    @user = recipient
    to_email = "#{recipient.title} <#{recipient.email}>"
    subject = I18n.t(:you_have_n_unread_notifications, n: notifications.count, locale: locale)
    I18n.with_locale(locale) do
      mail to: to_email, subject: subject
    end
  end

end