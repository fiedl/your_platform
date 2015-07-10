# This class wraps a received email.
#
# Initialize from a mail message string like this:
#
#     mail = ReceivedMail.new(message)
# 
#     mail.content
#     mail.text
#     mail.sender_email
#     mail.sender
#     mail.recipient_emails
#     mail.recipients
#     mail.message_id
#     mail.content_type
#
# where `message` might be
# 
#     "
#     From: John Doe <j.doe@example.com>
#     To: Jane Doe <jane@example.com>, ...
#     Subject: Foo Bar
#     This is a test.
#     "
#
# We adopted the conversion ideas from:
# https://github.com/ivaldi/brimir
#
# On future conversion/encoding issues, check:
#   * http://stackoverflow.com/q/4868205/2066546
#   * http://stackoverflow.com/a/15851602/2066546
#
class ReceivedMail
  
  def initialize(message)
    require 'mail'
    @message = message
    @email = Mail.new(message)
    return self
  end
  
  def content
    if @email.multipart?
      if @email.html_part
        @content_type = 'html'
        normalize_body(@email.html_part, @email.html_part.charset)
      elsif @email.text_part
        @content_type = 'text'
        normalize_body(@email.text_part, @email.text_part.charset)
      else
        @content_type = 'html'
        normalize_body(@email.parts[0], @email.parts[0].charset)
      end
    else
      @content_type = 'text'
      if @email.charset
        normalize_body(@email, @email.charset)
      else
        encode(@email.body.decoded)
      end
    end
  end
  def content_without_quotes
    content
      .gsub(/<style.*<\/style>/im, "")
      .gsub(/<head.*<\/head>/im, "")
      .gsub(/<blockquote.*<\/blockquote>/im, "")
      .gsub(/Am [0-9].*schrieb.*/im, "")
      .gsub(/On [0-9].*wrote:.*/im, "")
      .gsub(/----.*/m, "")
  end
    
  def subject
    if @email.charset
      encode(@email.subject.to_s.force_encoding(@email.charset))
    else
      @email.subject.to_s.encode('UTF-8')
    end
  end
  
  def sender_email
    @email.from.first
  end
  def sender_string
    @email.header[:from].value
  end
  def sender_name
    sender_string.gsub(" <#{sender_email}>", "")
  end
  def sender
    sender_by_email || sender_by_name
  end
  def sender_user
    sender if sender.kind_of?(User)
  end
  def sender_by_email
    ProfileFieldTypes::Email.where(value: sender_email).first.try(:profileable)
  end
  def sender_by_name
    User.find_by_name sender_name
  end
  
  def recipient_emails
    @email.smtp_envelope_to
  end
  def recipient_email
    recipient_emails.first
  end
  def recipients
    recipient_emails.collect do |email|
      recipient_by_email(email)
    end.uniq - [nil]
  end
  def recipient_by_email(email)
    ProfileFieldTypes::Email.where(value: email).first.try(:profileable)
  end
  
  def message_id
    @email.message_id
  end
  def content_type
    @content_type || content
    return @content_type
  end
  
  def attachments
    @email.attachments
  end
  def has_attachments?
    @email.has_attachments?
  end
  
  private
  
  def encode(string)
    string.encode('UTF-8', invalid: :replace, undef: :replace)
  end
  
  def normalize_body(part, charset)
    encode(part.body.decoded.force_encoding(charset))
  end
end