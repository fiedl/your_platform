class ReceivedCommentMail < ReceivedMail
  
  # This returns the post this email concerns.
  #
  # In this example
  #   user-aeng9iLei8lahso9shohfu0vaeth4oom2kooloi2iSh7Hahr.post-345.create-comment.plattform@example.com
  # the post is:
  #   Post.find(345)
  #
  def post_id
    @post_id ||= self.recipient_email.match(/\.post-([0-9]*)\./)[1].to_i
  end
  def post
    Post.find(post_id) if post_id > 0
  end

  # This returns the user, which is the comment's author.
  # We don't just use the email to identify the user, since it might be that the user
  # sends from a different email address.
  #
  # In this example
  #   user-aeng9iLei8lahso9shohfu0vaeth4oom2kooloi2iSh7Hahr.post-345.create-comment.plattform@example.com
  # the user is:
  #   User.find_by_token(aeng9iLei8lahso9shohfu0vaeth4oom2kooloi2iSh7Hahr)
  #
  def user_token
    @user_token ||= self.recipient_email.match(/user-([^\.]*)./)[1]
  end
  def user
    User.find_by_token(user_token) if user_token.present?
  end
  
  # This extracts the comment from the text part of the email.
  #
  def comment_text
    ActionController::Base.helpers.strip_tags(content_without_quotes).strip
  end

  def store_as_comment
    comment = post.comments.build
    comment.text = comment_text
    comment.author = user
    comment.save
    return comment
  end
    
  # Generate the email address that triggers a comment for the given post from the given user.
  #
  # Example: 
  #   user-aeng9iLei8lahso9shohfu0vaeth4oom2kooloi2iSh7Hahr.post-345.create-comment.plattform@example.com
  #
  def self.generate_address(user, post)
    user_token = user.account.try(:auth_token) || raise('no user auth token')
    post_id = post.try(:id) || raise('no post id')
    domain = AppVersion.email_domain || raise('no domain')
    return "user-#{user_token}.post-#{post_id}.create-comment.plattform@#{domain}"
  end
  
end