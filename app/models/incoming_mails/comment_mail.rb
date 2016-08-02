# This handles incoming emails that need to be processed into comments.
# A comment is created if the `in_reply_to` object is commentable.
#
class IncomingMails::CommentMail < IncomingMail

  def process(options = {})
    if authorized?
      comment = commentable.comments.create message_id: message_id,
        author_user_id: sender_user.id, text: text_content

      comment.incoming_mail_id = self.id
      comment.save

      [comment]
    else
      []
    end
  end

  def commentable
    in_reply_to_commentable
  end

  def authorized?
    commentable && sender_user.try(:can?, :create_comment_for, commentable)
  end

end