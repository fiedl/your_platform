class PostMailer < ActionMailer::Base
  helper MailerHelper
  default from: 'wingolfsplattform@wingolf.org'
  
  def post_email(text, recipients, subject, current_user)
    to_emails = recipients.collect { |user| "#{user.title} <#{user.email}>" }
    @text = text
    @subject = subject.gsub(/\[.*\]/, '')
    mail to: to_emails, from: current_user.email, subject: subject
  end
end
