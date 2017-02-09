class ContactMessage < MailForm::Base
  attribute :subject
  attribute :name, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message

  # Spam protection: A spam roboter would fill out this field, which will be hidden
  # via css. The field is validated to be blank, since a real user can't see the
  # field.
  #
  attribute :nickname, captcha: true

  def headers
    {
      subject: (subject || AppVersion.app_name),
      to: Setting.support_email,
      cc: email,
      from: %("#{name}" <#{email}>)
    }
  end
end