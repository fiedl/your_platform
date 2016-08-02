# This handles incoming emails that need to be processed into comments.
# A comment is created if the `in_reply_to` object is commentable.
#
class IncomingMails::CommentMail < IncomingMail

  def process(options = {})
    if authorized?
      comment = commentable.comments.create author_user_id: sender_user.id, text: text_content
      [comment]
    else
      []
    end
  end

  def commentable
    # TODO: Wenn jemand auf einen Kommentar antwortet, muss es natürlich
    # wieder ein Kommentar auf den Post werden.

    @commentable ||= Post.where(message_id: in_reply_to_message_id).last
  end

  def authorized?
    commentable && sender_user.try(:can?, :create_comment_for, commentable)
  end

end