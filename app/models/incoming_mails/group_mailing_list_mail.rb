# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if recipient_group && authorized?
      deliveries = recipient_group.members.with_account.collect do |user|
        new_message = self.message.clone
        #new_message.smtp_envelope_from = bounces_address
        new_message.smtp_envelope_to = user.email
        new_message.subject = subject_with_group_name
        new_message.deliver_with_action_mailer_now
      end
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

end
