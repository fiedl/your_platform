class Post < ActiveRecord::Base
  attr_accessible :author_user_id, :external_author, :group_id, :sent_at, :sticky, :subject, :text, :sent_via if defined? attr_accessible

  belongs_to :group
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'
  belongs_to :incoming_mail

  has_many :attachments, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :attachments
  attr_accessible :attachments_attributes

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :mentions, as: :reference, dependent: :destroy
  has_many :directly_mentioned_users, through: :mentions, class_name: 'User', source: 'whom'

  has_many :deliveries, as: :deliverable
  has_many :notifications, as: :reference, dependent: :destroy

  def deliveries
    if self.message_id
      Delivery.where(message_id: self.message_id)
    else
      super
    end
  end

  def associate_deliveries
    Delivery.where(message_id: message_id, deliverable_id: nil).update_all deliverable_type: 'Post', deliverable_id: id
  end

  include PostDeliveryReport

  def title
    subject
  end

  def mentioned_users
    directly_mentioned_users + comments.collect { |comment| comment.mentioned_users }.flatten
  end

  # This determines if the user has not read any part of this conversation,
  # which can be used to highlight the post in a collection.
  #
  # The post is considered unread if either the notifications for the post
  # or any notification for a comment on this post are unread.
  #
  def unread_by?(user)
    self.notifications.where(recipient_id: user.id, read_at: nil).count > 0 or
    user.notifications.unread.where(reference_type: 'Comment', reference_id: self.comment_ids).count > 0
  end

  def recipients
    User.find(notifications.pluck(:recipient_id))
  end

  # This allows to set the author either as email or as email string.
  #
  def author=(author)
    if author.kind_of? User
      super(author)
    elsif author.kind_of? String
      users_by_email = User.find_all_by_email(author)
      user_by_email = users_by_email.first if users_by_email.count == 1
      if user_by_email
        super(user_by_email)
      else
        self.external_author = author
      end
    end
  end
  def author
    super || external_author
  end

  # In order to do the encoding conversion properly,
  # we have to find out the former encoding from the mail header.
  #
  # parameter: Mail object
  # #<Mail::Part:-570274288, Multipart: false, Headers: <Content-Type: text/html; charset=windows-1252>,
  #   <Content-Transfer-Encoding: quoted-printable>>
  #
  def self.mail_encoding(mail)
    mail.inspect.to_s.scan(/.charset=(.*)>./)[0][0].split(">").first if mail
  end


  # This returns the text attribute, i.e. the message body, without html tags,
  # which could be used in block quotes, where only an excerpt of the message
  # is shown. (Use this to avoid opened but not closed html tags.)
  #
  def text_without_html_tags
    # http://stackoverflow.com/questions/7414267/strip-html-from-string-ruby-on-rails
    HTML::FullSanitizer.new.sanitize(self.text)
  end


  # Delivering Post as Email to All Group Members
  # ==========================================================================================

  def notify_recipients
    send_as_email_to_recipients
  end
  def send_as_email_to_recipients(recipients = nil)
  #  recipients ||= group.members
  #
  #  recipients.each do |recipient_user|
  #    unless self.deliveries.pluck(:user_id).include? recipient_user.id
  #      delivery = self.deliveries.build
  #      delivery.user = recipient_user
  #      delivery.save
  #    end
  #  end
  #
  #  self.deliveries.due.pluck(:id).each do |delivery_id|
  #    PostDelivery.delay.deliver_if_due(delivery_id)
  #  end
  #
  #  self.notifications.where(sent_at: nil).update_all sent_at: Time.zone.now
  #
  #  return self.deliveries.count
  end

  def email_subject
    subject.include?("[") ? subject : "[#{group.name}] #{subject}"
  end


  # Find all posts that are sent by or sent to a user.
  #
  def self.by_user(user)
    from_or_to_user(user)
  end
  def self.from_or_to_user(user)
    ids = from_user(user).pluck(:id) + to_user_via_group(user).pluck(:id) + to_user_via_mention(user).map(&:id)
    Post.where(id: ids).uniq.order(:created_at)
  end
  def self.from_user(user)
    self.where(author_user_id: user.id)
  end
  def self.to_user_via_group(user)
    self.where(group_id: user.group_ids)
  end
  def self.to_user_via_mention(user)
    user.mentions.collect do |mention|
      if mention.reference.kind_of? Post
        mention.reference
      elsif mention.reference.kind_of?(Comment) && mention.reference.commentable.kind_of?(Post)
        mention.reference.commentable
      end
    end
  end

end
