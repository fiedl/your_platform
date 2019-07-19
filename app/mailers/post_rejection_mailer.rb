class PostRejectionMailer < BaseMailer

  def post_rejection_email(sender_email, recipient_name, subject, reason)
    @recipient_name = recipient_name
    @subject = subject
    @reason = reason
    @from = 'no-reply@yourplatform.io'

    mail_message = mail(to: sender_email, subject: @subject, from: @from)
    mail_message.allow_recipients_without_account!
    mail_message
  end
end