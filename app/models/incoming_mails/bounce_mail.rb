# This handles incoming emails that is bounced, i.e. a notice by the recipient
# server that the message could not be delivered.
#
# This will mark the corresponding delivery as failed and increase the bounce
# counter for the address.
#
# If the bounce counter surpasses a certain threshold, the address is marked as
# unreachable, causing an administration issue to be created for the responsible
# admin.
#
class IncomingMails::BounceMail < IncomingMail

  # https://en.wikipedia.org/wiki/Bounce_message
  # TODO: Wir müssen aufpassen, dass unsere eigenen Bounce-Mails keinen Envelope-From haben, sodass Mail-Loops verhindert werden.
  # TODO: auto replies should be sent to the Return-Path

  def process(options = {})
    if bounced?
      raise 'no delivery found' if rejected_delivery.nil?
      rejected_delivery.update failed_at: Time.zone.now
      increase_bounce_counter_for rejected_recipient_email
      invalidate rejected_recipient_email if bounce_counter_for(rejected_recipient_email) > max_bounce_count_before_invalidation
    end
  end

  # Use this address to send bounces to:
  # http://stackoverflow.com/a/1247155/2066546
  #
  def self.bounces_address
    "bounces@#{AppVersion.incoming_email}"
  end

  def bounced?
    message.bounced?
  end

  def rejected_message
    Mail.new(message.parts.last.body) if bounced?
  end

  def rejected_message_id
    rejected_message.message_id if bounced?
  end

  def rejected_recipient_email
    rejected_message.destinations.first if bounced?
  end

  def rejected_delivery
    @rejected_delivery ||= Delivery.where(message_id: rejected_message_id).first if bounced?
  end

  def bounce_counter_for(address)
    Rails.cache.fetch(["IncomingMails::BounceMail", "bounce_counter_for", address], expires_in: 3.months) { 0 }
  end

  def set_bounce_counter_for(address, counter)
    Rails.cache.write ["IncomingMails::BounceMail", "bounce_counter_for", address], counter.to_i, expires_in: 3.months
  end

  def increase_bounce_counter_for(address)
    set_bounce_counter_for address, bounce_counter_for(address) + 1
  end

  def max_bounce_count_before_invalidation
    10
  end

  def invalidate(address)
    ProfileFieldTypes::Email.where(value: address).first.try(:needs_review!)
  end
end
