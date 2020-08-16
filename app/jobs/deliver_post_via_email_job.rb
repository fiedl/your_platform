class DeliverPostViaEmailJob < ApplicationJob
  queue_as :mailgate

  def perform(post_id:, recipient_user_id:)
    recipient = User.find recipient_user_id
    PostDelivery.where(post_id: post.id, user_id: recipient_user.id).first_or_create.deliver_if_due
  end
end