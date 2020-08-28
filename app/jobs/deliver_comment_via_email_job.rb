class DeliverCommentViaEmailJob < ApplicationJob
  queue_as :mailgate

  def perform(comment_id:)
    comment = Comment.find comment_id
    comment.deliver_now
  end
end