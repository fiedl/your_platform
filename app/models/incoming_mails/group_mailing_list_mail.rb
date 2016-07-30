# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if sender_user && recipient_group && authorized?
      recipient_group.members.with_account.collect do |user|
        message = Mail.new(raw_message)
        message.smtp_envelope_to = user.email
        message.subject = subject_with_group_name
        message.deliver_with_action_mailer_now

        # TODO: Persist delivery that it can be seen in the delivery reports!
        # TODO: Return Delivery
      end
    else
      []
    end
  end

  def authorized?
    sender_user || raise('Cannot determine sender user.')
    recipient_group || raise('Cannot determine recipient group.')
    sender_user.can? :create_post_for, recipient_group
  end

  def subject_with_group_name
    if subject.include? recipient_group.name
      subject
    else
      "[#{recipient_group.name}] #{subject}"
    end
  end

end