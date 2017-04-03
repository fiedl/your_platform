class PostRejectionMailer < BaseMailer

  def post_rejection_email(sender_email, recipient_name, subject, reason)
    @recipient_name = recipient_name
    @subject = subject
    @reason = reason
    @from = 'no-reply@your-platform.org'

    mail to: sender_email, subject: @subject, from: @from
  end
end