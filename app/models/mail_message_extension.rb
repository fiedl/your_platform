# This is prepended to Mail::Message.
# https://github.com/mikel/mail/blob/master/lib/mail/message.rb
#
module MailMessageExtension

  # This method overrides the original delivery method in order to
  # handle cases where the message cannot be delivered. In those
  # cases, the email adress is marked as 'invalid'.
  #
  def deliver
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

  # http://stackoverflow.com/a/15818886/2066546
  def body_in_utf8
    require 'charlock_holmes/string'
    body = self.body.decoded
    if body.present?
      encoding = body.detect_encoding[:encoding]
      body = body.force_encoding(encoding).encode('UTF-8')
    end
    return body
  end

  # For forwarding a modified message through action mailer, we need to deliver
  # the message object. But in order to do that we need to import some settings
  # from action mailer.
  #
  def deliver_with_action_mailer_now
    #action_delivery = ActionMailer::MessageDelivery.new(nil, nil)
    #action_delivery.__setobj__(self)
    #ActionMailer::DeliveryMethods.wrap_delivery_behavior(self, Rails.application.config.action_mailer.delivery_method)
    # action_delivery.delivery_method Rails.application.config.action_mailer.delivery_method
    #action_delivery.deliver!
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

end
