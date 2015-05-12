class SupportRequestMailer < BaseMailer
  helper AvatarHelper

  def support_request_email(sender_user, receiver_email, text, meta_data, navable)
    @sender_user = sender_user
    @text = text
    @meta_data = meta_data
    @navable = navable
    @role = meta_data[:role]
    @subject = (text.split("\n") - [nil, "", "Lieber Bundesbruder Kornder,"]).first
    
    mail to: [receiver_email], from: sender_user.email, subject: @subject
  end
  
end
