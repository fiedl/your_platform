class SupportRequestMailer < BaseMailer
  helper AvatarHelper

  def support_request_email(sender_user, receiver_email, text, meta_data, navable)
    @sender_user = sender_user
    @text = text
    @meta_data = meta_data
    @navable = navable
    @role = meta_data[:role]
    @subject = (text.split("\n") - [nil, "", "Lieber Bundesbruder Kornder,"]).first.first(100)
    @from_email = sender_user.try(:email) || SupportRequestsController.support_email
    
    mail to: [receiver_email], from: @from_email, subject: @subject
  end
  
end
