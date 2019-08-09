require File.join(Gem.loaded_specs['mail'].full_gem_path, 'lib/mail/message')
require File.join(Gem.loaded_specs['extended_email_reply_parser'].full_gem_path, 'lib/extended_email_reply_parser/mail/message')

# This extends the mail message class, which is originally defined in
#
#     https://github.com/mikel/mail
#     https://github.com/mikel/mail/blob/master/lib/mail/message.rb
#
# and further extended in
#
#     https://github.com/fiedl/extended_email_reply_parser
#
module YourPlatformMailMessageExtensions

  # This method overrides the original delivery method in order to
  # handle cases where the message cannot be delivered. In those
  # cases, the email adress is marked as 'invalid'.
  #
  # Also make sure to only deliver emails to users with accounts.
  #
  def deliver
    Rails.logger.info "Beginning delivery of Mail::Message #{message_id} for #{recipient_address}."

    if Ability.new(nil).can? :use, :mail_delivery_account_filter
      Rails.logger.info "Mail delivery account filter: allow without account = #{@allow_recipients_without_account}, recipient is system address = #{recipient_is_system_address?}, recipient has account = #{recipient_has_user_account?}"
      return false unless @allow_recipients_without_account || recipient_is_system_address? || recipient_has_user_account?
    end

    check_anti_spam_criteria_for_address_field :from
    check_anti_spam_criteria_for_address_field :to

    if recipient_address.include?('@')
      begin
        Rails.logger.info "Sending mail smtp_envelope_to #{self.smtp_envelope_to.to_s}."
        return super
      rescue Net::SMTPFatalError, Net::SMTPSyntaxError => error
        Rails.logger.debug error
        Rails.logger.warn "smtp-envelope-to field: #{self.smtp_envelope_to.to_s}"
        Rails.logger.warn "to field: #{self.to.to_s}"
        Rails.logger.warn "recognized recipient address (address only!): #{recipient_address}"
        Rails.logger.warn error.message
        recipient_address_needs_review!
        return false
      rescue Net::SMTPServerBusy => error
        Rails.logger.debug error
        Rails.logger.warn "Net::SMTPServerBusy when sending message. Waiting 60 seconds and retrying then ..."
        sleep 60
        retry
      end
    else
      Rails.logger.info "Recipient address #{recipient_address} needs review. Not delivering."
      recipient_address_needs_review!
      return false
    end
  end

  def check_anti_spam_criteria_for_address_field(field_name)
    self[field_name].try(:value).to_s.split(",").each do |address_string|
      unless address_string.include?('"') and address_string.include?('<') and address_string.include?('@')
        raise 'Make sure the ' + field_name.to_s + ' field (currently ' + address_string + ') is formatted like "Foo" <bar@example.com>. Otherwise this message will be classified as spam by some servers.'
      end
    end
  end

  def allow_recipients_without_account!
    @allow_recipients_without_account = true
  end

  def content_type
    super || guess_content_type
  end

  def guess_content_type
    if body_in_utf8.include? "<p>"
      'text/html'
    else
      'text/plain'
    end
  end

  def recipient_address
    self.smtp_envelope_to.try(:first) || self.to.try(:first)
  end

  def recipient_address_needs_review!
    raise RuntimeError, 'no recipient address' unless recipient_address.present?
    if profile_field = recipient_email_profile_field
      Rails.logger.warn "Adding :needs_review flag to email address #{recipient_address}."
      profile_field.needs_review!
    else
      Rails.logger.warn "Could not find matching email address #{recipient_address} in our database."
    end
  end

  # When we have an incoming email, the smtp envelope is already gone and unavailable
  # to this application. Thus, we need to read out the headers.
  #
  def smtp_envelope_to_header
    header_fields.select { |field| field.name.downcase.in? ['smtp-envelope-to', 'envelope-to'] }.collect { |field|
      value = field.value
      value = value.split("<").last.split(">").first if value && value.include?("<")
      value
    }
  end

  # The postfix transport might add the `RCPT TO` as `X-Original-To` header.
  # See: https://trello.com/c/ZbMA33GL/1021-e-mails-envelope
  # And: https://serverfault.com/questions/258469/how-to-configure-postfix-to-pipe-all-incoming-email-to-a-script#comment1270334_258491
  #
  def x_original_to
    value = header_fields.detect { |field| field.name.downcase == "x-original-to" }.try(:value)
    value = value.split("<").last.split(">").first if value && value.include?("<")
    value
  end

  # For forwarding a modified message through action mailer, we need to deliver
  # the message object. But in order to do that we need to import some settings
  # from action mailer.
  #
  def deliver_with_action_mailer_now
    import_delivery_method_from_actionmailer
    deliver
  end

  def import_delivery_method_from_actionmailer
    case ActionMailer::Base.delivery_method
    when :test
      delivery_method Mail::TestMailer
    when :smtp
      delivery_method Mail::SMTP, ActionMailer::Base.smtp_settings
    when :letter_opener
      delivery_method LetterOpener::DeliveryMethod, location: File.join(Rails.root, 'tmp/letter_opener')
    when :sendmail
      delivery_method Mail::Sendmail, location: '/usr/sbin/sendmail', arguments: '-i -t'
    end
  end

  # Replace a string in the message, e.g. a {{placeholder}}.
  #
  def replace(search, replace)
    if self.multipart?
      self.parts.each do |part|
        if part.text?
          part.body.raw_source.replace part.body.decoded.gsub(search, replace) if part.body.decoded.include? search
        end
      end
    else
      self.body.raw_source.replace self.body.decoded.gsub(search, replace) if self.body.decoded.include? search
    end
  end


  private

  def recipient_email_profile_field
    ProfileFields::Email.where(value: recipient_address).first if recipient_address.present?
  end

  def recipient_has_user_account?
    recipient_address.present? && User.find_by_email(recipient_address).try(:has_account?)
  end

  def recipient_is_system_address?
    recipient_address == Setting.support_email
  end

end

class Mail::Message
  prepend YourPlatformMailMessageExtensions
end
