class Comment < ApplicationRecord

  belongs_to :author, foreign_key: :author_user_id, class_name: 'User'
  belongs_to :commentable, polymorphic: true

  # has_many :mentions, as: :reference
  # has_many :mentioned_users, through: :mentions, class_name: 'User', source: 'whom'

  def recipients
    ([commentable.author] + commentable.comments.map(&:author)).uniq
  end

  def comment_emails
    raise 'this is only supported for post comments' unless commentable.kind_of? Post
    recipients.collect do |recipient|
      CommentMailer.comment_email(post: commentable, recipient: recipient)
    end
  end

  def deliver_now
    comment_emails.each(&:deliver_now)
  end

  def deliver_later
    DeliverCommentViaEmailJob.perform_later comment_id: self.id
  end

end
