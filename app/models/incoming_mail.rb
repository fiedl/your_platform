class IncomingMail

  def initialize(message)
    message = Mail::Message.new(message) if message.kind_of? String
    message.message_id ||= Mail::MessageIdField.new.value if Rails.env.development? # Because our test mails usually don't have a message id.

    @message = message
  end

  def self.from_message(message)
    return self.new(message)
  end

  def message
    @message
  end

  def message_id
    message.message_id
  end

  def in_reply_to_message_id
    message.in_reply_to
  end

  def from
    message.from
  end

  def to
    message.to
  end

  def cc
    message.cc
  end

  def envelope_to
    if message.smtp_envelope_to_header.any?
      message.smtp_envelope_to_header
    else
      message.smtp_envelope_to
    end
  end

  def x_original_to
    message.x_original_to
  end

  def subject
    message.subject
  end

  def text_content
    ExtendedEmailReplyParser.extract_text(message)
  end

  def destinations
    if x_original_to
      [x_original_to]
    elsif envelope_to.any?
      envelope_to
    else
      to + cc
    end
  end
  def destination
    raise "No destinations." if destinations.count == 0
    raise "The envelope contains several recipients: #{destinations.join(', ')}" if destinations.count > 1
    destinations.first
  end

  def sender_user
    sender_profileable if sender_profileable.kind_of? User
  end
  def sender_profileable
    sender_profileable_by_email || sender_by_name
  end
  def sender_profileable_by_email
    ProfileFields::Email.where(value: from).first.try(:profileable)
  end
  def sender_by_name
    User.find_by_name sender_name
  end
  def sender_email
    from
  end
  def sender_string
    message.header[:from].value
  end
  def sender_name
    sender_string.gsub(" <#{sender_email}>", "")
  end

  def recipient_group
    recipient_profileable if recipient_profileable.kind_of? Group
  end
  def recipient_profileable
    ProfileFields::MailingListEmail.where(value: destination).first.try(:profileable)
  end

  def authorized?
    recipient_group || raise('Cannot determine recipient group.')
    Ability.new(sender_user).can? :create_post_for, recipient_group
  end

  def self.processor_sub_classes
    # Does not work in development due to delayed constant auto loading:
    # # self.subclasses
    [
      IncomingMails::GroupMailingListMail,
      IncomingMails::MailWithoutAuthorization,
      IncomingMails::TestMail
    ]
  end

  def process(options = {})
    self.class.processor_sub_classes.collect do |incoming_mail_subclass|
      incoming_mail_subclass.from_message(message).process
    end.flatten
  end

end