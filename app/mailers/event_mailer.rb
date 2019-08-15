class EventMailer < ActionMailer::Base
  helper MailerHelper
  default from: "\"#{AppVersion.app_name}\" <#{Setting.support_email}>"

  def invitation_email(text, recipients, event, current_user)
    @text_before_event_table, @text_after_event_table = text.split('[ Informationen zur Veranstaltung werden vom System hier eingefügt. ]')
    @text_before_event_table ||= text
    @event = event

    recipients.each do |user|
      @recipient = user
      I18n.with_locale(user.locale) do
        Time.use_zone(@timezone = user.timezone) do
          mail to: "\"#{user.title}\" <#{user.email}>", from: "\"#{current_user.title}\" <#{current_user.email}>", subject: event.title
        end
      end
    end
  end

end
