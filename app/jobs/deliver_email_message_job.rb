class DeliverEmailMessageJob < ApplicaionJob
  queue_as :mailgate

  def perform(message)
    # TODO: Test whether serializing long messages works.
    # TODO: Test whether serializing UTF-8 🍕 works.

    message.deliver_with_action_mailer_now
  end
end