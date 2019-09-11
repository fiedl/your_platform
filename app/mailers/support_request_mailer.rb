class SupportRequestMailer < BaseMailer
  helper AvatarHelper

  def support_request_email(sender_user, receiver_email, text, meta_data, navable)
    @sender_user = sender_user
    @text = text
    @meta_data = meta_data
    @navable = navable
    @role = meta_data[:role]
    @from_email = "\"#{sender_user.title}\" <#{sender_user.email}>" if sender_user
    @from_email ||= SupportRequestsController.support_email

    mail_message = mail(to: [receiver_email], from: @from_email, subject: subject)
    mail_message.allow_recipients_without_account!
    mail_message
  end

  private

  def subject
    (@text.split("\n") - [nil, ""] - support_request_form_default_text.split("\n")).first.first(100)
  end

  def support_request_form_default_text
    render_to_string(partial: "support_requests/text_template", locals: {current_user: @sender_user})
  end
end
