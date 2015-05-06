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
    sender if sender.kind_of?(User)
  end
  
  def recipient_groups
    recipients.select { |recipient| recipient.kind_of? Group }
  end
  
  def store_as_posts
    recipient_groups.collect do |group|
      if group.posts.where(message_id: self.message_id).count == 0
        post = Post.new
        if self.sender_by_email
          post.author_user_id = self.sender_user.id
        elsif self.sender_by_name
          post.author_user_id = self.sender_user.id
          post.external_author = self.sender_string
        else
          post.external_author = self.sender_string
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