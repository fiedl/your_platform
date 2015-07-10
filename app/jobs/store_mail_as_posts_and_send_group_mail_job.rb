class StoreMailAsPostsAndSendGroupMailJob < ActiveJob::Base
  queue_as :mailgate
  
  def perform(message)
    received_post_mail = ReceivedPostMail.new(message)
    posts = received_post_mail.store_as_posts
    posts.each { |post| post.send_as_email_to_recipients }
  end
end