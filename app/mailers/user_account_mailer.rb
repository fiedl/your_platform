class UserAccountMailer < BaseMailer
  def welcome_email(user, password)
    @user = user
    @password = password
    @mr_or_mrs = @user.female? ? t(:mrs) : t(:mr)

    @subject = I18n.t :welcome_to_app_name, app_name: AppVersion.app_name

    to = "#{@user.title} <#{@user.email}>"

    I18n.with_locale(@user.locale) do
      mail to: [to], subject: @subject
    end

  end
end
