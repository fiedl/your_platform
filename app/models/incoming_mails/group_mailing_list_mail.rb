# This class handles the direct forwarding of an incoming
# group mailing list message to the members of the group.
#
class IncomingMails::GroupMailingListMail < IncomingMail

  def process(options = {})
    if recipient_group && authorized?
      create_post_later
      deliver_message_to_earch_user_later
    else
      []
    end
  end

  def deliver_message_to_earch_user_later
    deliveries = recipient_group.members.with_account.collect do |user|

      # Create a copy of the original message.
      # `self.message.clone` and `self.message.dup` would keep certain references,
      # such that modifying the body would modify the body for all further messages
      # in the loop.
      new_message = Mail::Message.new self.message.to_s

      new_message.from = formatted_from
      new_message.reply_to = formatted_from
      new_message.return_path = BaseMailer.delivery_errors_address
      new_message.sender = BaseMailer.default[:from]
      new_message.to = formatted_to_field
      new_message.cc = formatted_cc_field
      new_message.smtp_envelope_to = user.email
      fill_in_placeholders new_message, from_user: sender_user, to_user: user
      new_message.deliver_with_action_mailer_later
    end
    deliveries
  end

  def create_post_later
    CreatePostFromEmailMessageJob.perform_later(raw_message: message.to_s)
  end

  def create_post
    post = recipient_group.posts.new
    if sender_user
      post.author_user_id = sender_user.id
    else
      post.external_author = sender_string
    end
    post.sent_at = message.date || Time.zone.now
    post.subject = message.subject
    post.content_type = message.content_type
    post.text = message.text
    post.message_id = message.message_id
    post.sent_via = destination
    post.save
    if message.has_attachments?
      message.attachments.each do |attachment|
        file = StringIO.new(attachment.decoded)
        file.class.class_eval { attr_accessor :original_filename, :content_type }
        file.original_filename = attachment.filename
        file.content_type = attachment.mime_type
        post_attachment = post.attachments.create(file: file)
        post_attachment.save
      end
    end
    post
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

  def formatted_field(header_key)
    if message[header_key]
      parts = message[header_key].address_list.addresses.collect do |part|
        part = formatted_to if part.address == destination
        part.to_s
      end
      parts.join(", ")
    end
  end

  def formatted_to_field
    formatted_field("To")
  end

  def formatted_cc_field
    formatted_field("CC")
  end

  PERSONAL_GREETING_PLACEHOLDERS = ["{{anrede}}", "{{greeting}}"]

  def fill_in_placeholders(message, options = {})
    PERSONAL_GREETING_PLACEHOLDERS.each do |placeholder|
      message.replace placeholder, personal_greeting(options[:from_user], options[:to_user])
    end
  end

  def personal_greeting(from_user, to_user)
    if to_user
      to_user.personal_greeting(current_user: from_user)
    else
      I18n.t(:good_day).to_s.gsub(",", "").gsub("!", "")
    end
  end

end
