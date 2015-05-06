# This class wraps a message string and extracts information that is
# needed to store the message as Post in our database.
#
#     mail = ReceivedPostMail.new(message)
# 
#     mail.content
#     mail.sender_email
#     mail.sender_user
#     mail.recipient_groups
#     mail.message_id
#     mail.content_type
#
class ReceivedPostMail < ReceivedMail
  
  def sender_user
    sender.kind_of?(User) || raise('The sender of the message should be a User.')
    sender
  end
  
  def recipient_groups
    recipients.select { |recipient| recipient.kind_of? Group }
  end
  
  def store_as_posts
    recipient_groups.collect do |group|
      if group.posts.where(message_id: self.message_id).count == 0
        post = Post.new
        if self.sender_user
          post.author_user_id = self.sender_user.id
        else
          post.external_author = self.sender_email
        end
        raise 'something is wrong. this group is not a recipient' unless group.in?(self.recipient_groups)
        post.group_id = group.id
        post.sent_at = Time.zone.now
        post.subject = self.subject
        post.text = self.content
        post.content_type = self.content_type
        post.message_id = self.message_id
        post.save
        post
      end
    end
  end

end