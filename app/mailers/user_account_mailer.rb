class UserAccountMailer < ActionMailer::Base
  def welcome_email( user, password ) 
    @user = user
    @password = password
    @bundesbruder_or_philister = @user.philister? ? "Philister" : "Bundesbruder"
    
    # Bundesbrüder, die nur in Estland aktiv sind, bekommen diese E-Mail auf englisch,
    # alle anderen auf deutsch.
    #
    if @user.cached(:corporations).collect { |corporation| corporation.token } == ["Dp"]
      locale = :en
    else
      locale = :de
    end
    
    
    to = "#{@user.name} <#{@user.email}>"
    
    I18n.with_locale(locale) do
      mail to: to, subject: t( :welcome_to_wingolfsplattform )
    end
    
  end
end
