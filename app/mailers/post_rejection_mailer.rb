class PostRejectionMailer < BaseMailer
  default from: 'no-reply@your-platform.org'
  
  def post_rejection_email(sender_email, recipient_name, subject, reason)
    @recipient_name = recipient_name
    @subject = subject
    @reason = reason
    
    mail to: sender_email, subject: @subject
  end
end