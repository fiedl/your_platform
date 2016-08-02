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
  def deliver
    if recipient_address.include?('@')
      begin
        Rails.logger.info "Sending mail smtp_envelope_to #{self.smtp_envelope_to.to_s}."
        result = super
        create_delivery
        return result
      rescue Net::SMTPFatalError, Net::SMTPSyntaxError => error
        Rails.logger.debug error
        Rails.logger.warn "smtp-envelope-to field: #{self.smtp_envelope_to.to_s}"
        Rails.logger.warn "to field: #{self.to.to_s}"
        Rails.logger.warn "recognized recipient address (address only!): #{recipient_address}"
        Rails.logger.warn error.message
        create_failed_delivery comment: error.message
        recipient_address_needs_review!
        return false
      rescue Net::SMTPServerBusy => error
        Rails.logger.debug error
        Rails.logger.warn "Net::SMTPServerBusy when sending message. Waiting 60 seconds and retrying then ..."
        sleep 60
        retry
      end
    else
      recipient_address_needs_review!
      return false
    end
  end

  def recipient_address
    self.smtp_envelope_to.try(:first) || self.to.try(:first)
  end

  def recipient_address_needs_review!
    raise 'no recipient address' unless recipient_address.present?
    if profile_field = ProfileFieldTypes::Email.where(value: recipient_address).first
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
    header_fields.select { |field| field.name.downcase.in? ['smtp-envelope-to', 'envelope-to'] }.map(&:value)
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
    case Rails.application.config.action_mailer.delivery_method
    when :test
      delivery_method Mail::TestMailer
    when :smtp
      delivery_method Mail::SMTP, Rails.application.config.action_mailer.smtp_settings
    when :letter_opener
      delivery_method LetterOpener::DeliveryMethod, location: File.join(Rails.root, 'tmp/letter_opener')
    when :sendmail
      delivery_method Mail::Sendmail, location: '/usr/sbin/sendmail', arguments: '-i -t'
    end
  end

  def create_delivery
    Delivery.create message_id: message_id,
      in_reply_to: in_reply_to,
      user_email: recipient_address,
      user_id: User.find_by_email(recipient_address).try(:id),
      subject: subject,
      sent_at: (date || Time.zone.now)
  end

  def create_failed_delivery(options = {})
    delivery = create_delivery
    delivery.sent_at = nil
    delivery.failed_at = Time.zone.now
    delivery.comment = options[:comment]
    delivery.save
    delivery
  end

  def find_delivery
    Delivery.where(message_id: message_id, user_email: recipient_address).last
  end

  def delivery
    find_delivery || create_delivery
  end

end

class Mail::Message
  prepend YourPlatformMailMessageExtensions
end
