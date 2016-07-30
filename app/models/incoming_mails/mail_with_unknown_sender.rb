# This class handles processing of incoming emails where the sender
# cannot be found in our database. The sender will receive a message
# back that explains the situation. Maybe he has used the wrong email
# address to send.
#
class IncomingMails::MailWithUnknownSender < IncomingMail

  def process(options = {})
    if sender_user
      if sender_user.account
        []
      else
        notify_about_missing_account
      end
    else
      notify_about_missing_user_record
    end
  end

  private

  def notify_about_missing_user_record
    rejection_mail = PostRejectionMailer.post_rejection_email from, destinations.join(", "),
      "Re: #{subject}", I18n.t(:we_could_not_determine_who_you_are)
    rejection_mail.deliver_now
    return [rejection_mail]
  end

  def notify_about_missing_account
    rejection_mail = PostRejectionMailer.post_rejection_email from, destinations.join(", "),
      "Re: #{subject}", I18n.t(:your_account_is_inactive_please_reply)
    rejection_mail.deliver_now
    return [rejection_mail]
  end

end