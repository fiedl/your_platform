class Mention < ActiveRecord::Base
  belongs_to :who, foreign_key: 'who_user_id', class_name: 'User'
  belongs_to :whom, foreign_key: 'whom_user_id', class_name: 'User'
  belongs_to :reference, polymorphic: true
  
  # Create mentions from, for example, a Comment:
  #
  #     Mention.create_multiple(current_user, comment, comment.text)
  #
  # where `comment.text` is, for example,
  #
  #     "I've invited @[[John Doe]] to our conversation."
  #
  def self.create_multiple(current_user, reference, text)
    mentions = []
    text.scan(/@\[\[([^\]]*)\]\]/) do |match|
      mention = Mention.create
      mention.who = current_user
      mention.whom = User.find_by_title(match[0])
      mention.reference = reference
      mention.save
      
      mentions += [mention]
    end
    return mentions
  end
  
  def reference_title
    if reference.respond_to? :title
      reference.title
    else
      reference.commentable.title if reference.kind_of? Comment
    end
  end
  
  def self.create_multiple_and_notify_instantly(current_user, reference, text)
    mentions = Mention.create_multiple(current_user, reference, text)
    users_to_notify_immediately = []
    mentions.each do |mention|
      notifications = Notification.create_from_mention(mention)
      users_to_notify_immediately += notifications.map(&:recipient).uniq
    end
    users_to_notify_immediately.each { |user| Notification.deliver_for_user(user) }
    return mentions
  end
  
end
