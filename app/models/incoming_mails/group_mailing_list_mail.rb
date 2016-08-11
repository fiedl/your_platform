# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if recipient_group && authorized?
      deliveries = recipient_group.members.with_account.collect do |user|
        message = Mail.new(raw_message)
        message.smtp_envelope_from = bounces_address
        message.smtp_envelope_to = user.email
        message.subject = subject_with_group_name
        message.deliver_with_action_mailer_now
        message.delivery
      end
      associate_corresponding_post
      deliveries
    else
      []
    end
  end

  def subject_with_group_name
    if subject.include? recipient_group.name
      subject
    else
      "[#{recipient_group.name}] #{subject}"
    end
  end

  def associate_corresponding_post
    find_corresponding_post.try(:associate_deliveries) if message_id
  end

  def find_corresponding_post
    @post ||= Post.where(message_id: message_id, created_at: 1.hour.ago..Time.zone.now).first
  end

  # We override SMTP's `FROM MAIL` (="smtp envelope from"), which differs from
  # the  `From:` header. The recipients' mail servers use this address to send
  # bounces to, i.e. will send their delivery errors to that address.
  # See: http://stackoverflow.com/a/1247155/2066546
  #
  # We don't want the sender of a message receive the bounce messages but let
  # the mail system handle those.
  #
  # They are handled in `IncomingMails::BounceMail`. Therefore, use the same
  # address as there.
  #
  def bounces_address
    IncomingMails::BounceMail.bounces_address
  end

end
