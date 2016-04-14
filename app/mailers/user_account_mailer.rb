class UserAccountMailer < BaseMailer
  def welcome_email(user, password)
    @user = user
    @password = password
    @mr_or_mrs = @user.female? ? t(:mrs) : t(:mr)

    to = "#{@user.title} <#{@user.email}>"

    I18n.with_locale(@user.locale) do
      mail to: [to], subject: t(:welcome_to_the_new_intranet_platform)
    end

  end
end
