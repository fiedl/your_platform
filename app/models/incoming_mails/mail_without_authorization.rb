# This class handles processing of incoming emails where the sender
# is not authorized to send the email to our system. For example,
# the mailing lists have a setting which determines if users need
# a platform account to send emails.
#
# The user receives an email that explains the situation.
#
class IncomingMails::MailWithoutAuthorization < IncomingMail

  def process(options = {})
    if authorized?
      []
    elsif sender_user.nil?
      notify_about_missing_user_record
    elsif sender_user.account.nil?
      notify_about_missing_account
    else
      notify_about_unauthorized
    end
  end

  private

  def notify_about_missing_user_record
    deliver_rejection_email I18n.t(:we_could_not_determine_who_you_are)
  end

  def notify_about_missing_account
    deliver_rejection_email I18n.t(:your_account_is_inactive_please_reply)
  end

  def notify_about_unauthorized
    deliver_rejection_email I18n.t(:you_are_unauthorized_to_send_to_this_mailing_list)
  end

  def deliver_rejection_email(reason)
    rejection_mail = PostRejectionMailer.post_rejection_email from, destinations.join(", "),
      subject, reason
    rejection_mail.in_reply_to = message_id
    rejection_mail.deliver_now
    return [rejection_mail]
  end

end