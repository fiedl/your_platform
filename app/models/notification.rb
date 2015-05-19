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
  attr_accessible :recipient_id, :author_id, :reference_url, :reference_type, :reference_id, :message, :text, :sent_at
  
  belongs_to :recipient, class_name: 'User'
  belongs_to :author, class_name: 'User'
  belongs_to :reference, polymorphic: true
  
  scope :sent, -> { where.not(sent_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :upcoming, -> { where('sent_at IS NULL AND read_at IS NULL') }
  
  # Creates all notifications for users that should
  # be notified about this post.
  #  
  # Options:
  #   - sent_at    In order to mark a notification as already sent.
  #
  def self.create_from_post(post, options = {})
    post.group.members.collect do |group_member|
      locale = group_member.locale
      message = post.subject if not post.text.start_with?(post.subject)
      message ||= I18n.t(:has_posted_a_new_message, user_title: post.author.title, locale: locale) if post.author.kind_of?(User)
      message ||= I18n.t(:a_new_message_has_been_posted, locale: locale)
      
      self.create(
        recipient_id:   group_member.id,
        author_id:      post.author.kind_of?(User) ? post.author.id : nil,
        reference_url:  post.url,
        reference_type: post.class.name,
        reference_id:   post.id,
        message:        message,
        text:           post.text,
        sent_at:        options[:sent_at]
      )
    end
  end
  
  # Find all upcoming notifications for a given user.
  def self.upcoming_by_user(user)
    self.upcoming.where(recipient_id: user.id)
  end
  
  # Deliver the notifications.
  #
  def self.deliver
    User.where(id: self.upcoming.pluck(:recipient_id)).collect do |recipient|
      self.deliver_for_user(recipient)
    end
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
    if notifications.count > 0 and user.account and user.beta_tester?
      NotificationMailer.notification_email(user, notifications).deliver_now
      notifications.each { |n| n.update_attribute(:sent_at, Time.zone.now) }
    end
  end

end
