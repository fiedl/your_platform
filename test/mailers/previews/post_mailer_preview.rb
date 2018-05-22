class PostMailerPreview < ActionMailer::Preview

  def post_email
    post = Post.last
    recipients = [User.first]
    subject = post.title
    sender = post.author
    text = post.text
    group = post.group

    PostMailer.post_email(text, recipients, subject, sender, group, post)
  end

end