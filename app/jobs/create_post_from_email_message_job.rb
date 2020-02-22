class CreatePostFromEmailMessageJob < ApplicationJob
  queue_as :mailgate

  def perform(raw_message:)
    incoming_mail = IncomingMails::GroupMailingListMail.new(raw_message)
    incoming_mail.create_post
  end
end