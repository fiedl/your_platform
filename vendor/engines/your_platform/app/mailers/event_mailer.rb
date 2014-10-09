class EventMailer < ActionMailer::Base
  helper MailerHelper
  default from: 'wingolfsplattform@wingolf.org'
  
  def invitation_email(text, recipients, event, current_user)
    @text_before_event_table, @text_after_event_table = text.split('[ Informationen zur Veranstaltung werden vom System hier eingefügt. ]')
    @text_before_event_table ||= text
    @event = event
    
    to_emails = recipients.collect { |user| "#{user.title} <#{user.email}>" }
    mail to: to_emails, from: current_user.email, subject: event.title
  end
end
