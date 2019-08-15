class PostRejectionMailer < BaseMailer

  def post_rejection_email(sender_email, recipient_name, subject, reason)
    @recipient_name = recipient_name
    @subject = subject
    @reason = reason
    @to = "\"#{sender_email}\" <#{sender_email}>"

    mail_message = mail(to: @to, subject: @subject)
    mail_message.allow_recipients_without_account!
    mail_message
  end
end