class UserAccountMailer < ActionMailer::Base
  default from: "Wingolfsplattform <wingolfsplattform@erlanger-wingolf.de>"

  def welcome_email( user, password ) 
    @user = user
    @password = password
    to = "#{@user.name} <#{@user.email}>"
    mail to: to, subject: t( :welcome_to_wingolfsplattform )
  end
end
