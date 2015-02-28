module MailerHelper
  def user_links(users)
    users.collect do |user|
      link_to user.title, user_url(user)
    end.join(", ").html_safe
  end
end