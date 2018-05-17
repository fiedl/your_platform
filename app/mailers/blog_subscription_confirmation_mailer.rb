class BlogSubscriptionConfirmationMailer < BaseMailer

  def blog_subscription_confirmation_email(recipient, blog_title, confirmation_link)
    @user = recipient
    @blog_title = blog_title
    @confirmation_link = confirmation_link
    @subject = t :please_confirm_your_subscription_to_str, str: @blog_title

    mail to: recipient.email, subject: @subject, from: Setting.support_email
  end

end