# This class handles processing of incoming emails where the sender
# cannot be found in our database. The sender will receive a message
# back that explains the situation. Maybe he has used the wrong email
# address to send.
#
class IncomingMails::MailWithUnknownSender < IncomingMail

  def process
    if sender_user
      return []
    else
      rejection_mail = PostRejectionMailer.post_rejection_email from, destinations.join(", "),
        "Re: #{subject}", I18n.t(:we_could_not_determine_who_you_are)
      rejection_mail.deliver_now
      return [rejection_mail]
    end
  end

end