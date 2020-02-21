class DeliverEmailMessageJob < ApplicationJob
  queue_as :mailgate

  def perform(raw_message:, envelope_attributes: {})
    # TODO: Test whether serializing long messages works.
    # TODO: Test whether serializing UTF-8 🍕 works.

    message = Mail::Message.new(raw_message)
    envelope_attributes.each do |key, value|
      message.send "#{key}=", value
    end
    message.deliver_with_action_mailer_now
  end

end