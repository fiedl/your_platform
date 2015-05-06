class PostMailer < BaseMailer

  def post_email(text, recipients, subject, sender, group, post)
    to_emails = recipients.collect { |user| "#{user.title} <#{user.email}>" }
    @text = text
    @subject = subject.gsub(/\[.*\]/, '')
    @group = group
    @post = post
    mail to: to_emails, from: sender.email, subject: subject
  end
  
end
