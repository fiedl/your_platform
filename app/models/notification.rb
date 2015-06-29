# These objects store notifications for users, for example
# for posts or comments. Each user can choose his own notification
# policy, i.e. in which intervals notifications should be sent
# to him.
#
#     create_table :notifications do |t|
#       t.integer :recipient_id
#       t.integer :author_id
#       t.string :reference_url
#       t.string :reference_type
#       t.integer :reference_id
#       t.string :message
#       t.text :text
#       t.datetime :sent_at
#       t.datetime :read_at
# 
#       t.timestamps null: false
#     end
#
class Notification < ActiveRecord::Base
  attr_accessible :recipient_id, :author_id, :reference_url, :reference_type, :reference_id, :message, :text, :sent_at, :read_at
  
  belongs_to :recipient, class_name: 'User'
  belongs_to :author, class_name: 'User'
  belongs_to :reference, polymorphic: true
  
  scope :sent, -> { where.not(sent_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }
  scope :upcoming, -> { where('sent_at IS NULL AND read_at IS NULL') }
  
  # Creates all notifications for users that should
  # be notified about this post.
  #  
  # Options:
  #   - sent_at    In order to mark a notification as already sent.
  #
  def self.create_from_post(post, options = {})
    recipients = post.group.members
    recipients -= [post.author] if post.author.kind_of?(User) and not Rails.env.development?

    recipients.collect do |group_member|
      locale = group_member.locale
      message = post.subject if not post.text.start_with?(post.subject)
      message ||= I18n.t(:has_posted_a_new_message, user_title: post.author.title, group_name: post.group.name, locale: locale) if post.author.kind_of?(User)
      message ||= I18n.t(:a_new_message_has_been_posted, group_name: post.group.name, locale: locale)
      
      self.create(
        recipient_id:   group_member.id,
        author_id:      post.author.kind_of?(User) ? post.author.id : nil,
        reference_url:  post.url,
        reference_type: post.class.name,
        reference_id:   post.id,
        message:        message,
        text:           post.text,
        sent_at:        options[:sent_at]  # when the notification is sent via email
      )
    end
  end
  
  # Creates all notifications for users that should be 
  # notified about comments.
  #
  def self.create_from_comment(comment, options = {})
    recipients = []
    recipients += [comment.commentable.author] if comment.commentable.respond_to? :author
    recipients += comment.commentable.comments.map(&:author)
    recipients -= [comment.author]
    recipients = recipients.uniq - [nil]
    
    recipients.collect do |recipient|
      locale = recipient.locale
      message = I18n.t(:has_commented_on, user_title: comment.author.title, commentable_title: comment.commentable.title)
      
      self.create(
        recipient_id:   recipient.id,
        author_id:      comment.author.id,
        reference_url:  comment.url,
        reference_type: comment.class.name,
        reference_id:   comment.id,
        message:        message,
        text:           comment.text,
        sent_at:        options[:sent_at]  # when the notification is sent via email
      )
    end
  end
  
  # Creates notifications for users that are mentioned.
  #
  def self.create_from_mention(mention, options = {})
    recipients = [mention.whom]
    recipients.collect do |recipient|
      message = I18n.t(:has_mentioned_you_on, user_title: mention.who.title, reference_title: mention.reference_title)
      self.create(
        recipient_id:   recipient.id,
        author_id:      mention.who.id,
        reference_url:  mention.reference.url,
        reference_type: mention.reference.class.name,
        reference_id:   mention.reference.id,
        message:        message,
        text:           mention.reference.text,
        sent_at:        options[:sent_at]  # when the notification is sent via email
      )
    end
  end
  
  
  # Find all notifications that are due to be sent via email.
  # 
  def self.due
    self.upcoming.joins(:recipient).where(
      # Notifications that should be sent instantly, are always due.
      "(users.notification_policy = 'instantly')" +
      
      # Notifications that are to be sent daily, are due at 6 pm,
      # but only those that have been sent before. Otherwise, the user
      # will get multiple emails after 6 pm.
      " OR " + (Time.zone.now >= Time.zone.now.change(hour: 18) ? "(users.notification_policy = 'daily' AND notifications.created_at < ?)" : "? is null") + 
      
      # Notifications that are to be sent in letter bundles, 
      # are due under the following conditions:
      # * The last upcoming notification for that user has been
      #   created longer than 10 minutes ago.
      # * The first upcoming notification for that user has been
      #   created longer than 1 hour ago.
      " OR (users.notification_policy = 'letter_bundle' AND users.id IN (?))", 
      
      Time.zone.now.change(hour: 18),
      self.user_ids_where_letter_bundle_is_due
    )
  end

  # Notifications that are to be sent in letter bundles, 
  # are due under the following conditions:
  # * The last upcoming notification for that user has been
  #   created longer than 10 minutes ago.
  # * The first upcoming notification for that user has been
  #   created longer than 1 hour ago.
  #
  def self.user_ids_where_letter_bundle_is_due
    User.where(notification_policy: 'letter_bundle').includes(:notifications).select { |user|
      user.notifications.upcoming.count > 0 and
      (
        (user.notifications.upcoming.order('created_at asc').pluck(:created_at).last < Time.zone.now - self.letter_bundle_wait_time.min) or
        (user.notifications.upcoming.order('created_at asc').pluck(:created_at).first < Time.zone.now - self.letter_bundle_wait_time.max)
      )
    }.map(&:id)
  end
  
  # Find all upcoming notifications for a given user.
  def self.upcoming_by_user(user)
    self.upcoming.where(recipient_id: user.id)
  end
  
  # Deliver the notifications.
  #
  def self.deliver
    User.where(id: self.upcoming.pluck(:recipient_id).uniq).collect do |recipient|
      self.deliver_for_user(recipient)
    end.flatten - [nil]
  end
  
  # Deliver all upcoming notifications for a certain user.
  #
  # The notification mail is *not* sent:
  #   * if the user has no upcoming notifications
  #   * if the user has no account
  #   * if the user is no beta tester (TODO: notifications for all)
  #
  def self.deliver_for_user(user)
    notifications = self.upcoming_by_user(user)
    if notifications.count > 0 and user.account
      NotificationMailer.notification_email(user, notifications).deliver_now
      notifications.each { |n| n.update_attribute(:sent_at, Time.zone.now) }
      return notifications
    else
      return []
    end
  end
  
  # The time that notifications are delayed when they should be sent
  # as letter bundles.
  #
  # The notification systems waits the time period specified here
  # for new notifications to append before sending a notifications
  # email.
  #
  # For example, `10.minutes..1.hour` means that the system will at 
  # least 10 minutes, but not longer than an hour to send a 
  # notification after it has been created.
  #
  def self.letter_bundle_wait_time
    10.minutes..1.hour
  end

end
