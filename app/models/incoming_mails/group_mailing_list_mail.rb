# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if recipient_group && authorized?
      deliveries = recipient_group.members.with_account.collect do |user|
        new_message = self.message.clone
        new_message.smtp_envelope_from = bounces_address
        new_message.from = formatted_from
        new_message.to = formatted_to
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

  # To meet spam-protection requirements, re-format the "from" field if needed.
  #
  # https://trello.com/c/s94OXzul/1371-e-mails-554-570-reject
  # https://stackoverflow.com/q/57173606/2066546
  #
  def formatted_from
    if sender_user
      "\"#{sender_user.title}\" <#{sender_email}>"
    else
      if message[:from].value.include?("\"") && message[:from].value.include?("<")
        message[:from].value
      else
        "\"#{sender_email}\" <#{sender_email}>"
      end
    end
  end

  def formatted_to
    "\"#{recipient_group.title}\" <#{destination}>"
  end

end
