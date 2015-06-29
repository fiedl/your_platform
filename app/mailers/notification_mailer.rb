class NotificationMailer < BaseMailer
  helper AvatarHelper
  helper EmojiHelper
  helper QuickLinkHelper
  helper MentionsHelper
  
  def notification_email(recipient, notifications)
    locale = recipient.locale
    @notifications = notifications.order('created_at desc')
    @user = recipient
    to_email = "#{recipient.title} <#{recipient.email}>"
    subject = I18n.t(:you_have_n_unread_notifications, n: notifications.count, locale: locale)
    
    # The user may reply by email to the upmost post or comment.
    # Therefore, identify the corresponding post and generate a reply email.
    if @notifications.first.reference.kind_of? Post
      @reply_to_post = @notifications.first.reference
    elsif @notifications.first.reference.kind_of? Comment
      @reply_to_post = @notifications.first.reference.commentable if @notifications.first.reference.commentable.kind_of? Post
    end
    @reply_to = ReceivedCommentMail.generate_address(@user, @reply_to_post) if @reply_to_post
    
    I18n.with_locale(locale) do
      mail to: to_email, subject: subject, reply_to: @reply_to
    end
  end

end