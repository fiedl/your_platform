# Attributes:
#   t.string :raw_message
#   t.string :message_id
#   t.string :in_reply_to_message_id
#   t.string :from
#   t.text :to
#   t.text :cc
#   t.string :envelope_to
#   t.string :subject
#   t.text :content, limit: 1073741823
#   t.text :text_content, limit: 1073741823
#
class IncomingMail < ActiveRecord::Base
  mount_uploader :raw_message_file, RawMessageUploader
  validates :raw_message_file, presence: true, unless: :new_record?

  #has_many :processed_objects, polymorphic: true

  def self.create_and_process(message)
    self.create_from_message(message).process
  end

  def self.create_from_message(message)
    message = Mail::Message.new(message) if message.kind_of? String

    incoming_mail = self.new
    incoming_mail.message_id = message.message_id
    incoming_mail.in_reply_to_message_id = message.in_reply_to
    incoming_mail.from = message.from.try(:join, ", ")
    incoming_mail.to = message.to.try(:join, ", ")
    incoming_mail.cc = message.cc.try(:join, ", ")
    incoming_mail.envelope_to = message.smtp_envelope_to_header.try(:join, ", ") if message.smtp_envelope_to_header.any?
    incoming_mail.envelope_to ||= message.smtp_envelope_to.try(:join, ", ")
    incoming_mail.subject = message.subject
    incoming_mail.save!

    # Storing the raw message needs to come after `save!`
    # because the uploader needs the model to have an `id`.
    incoming_mail.raw_message = message

    return incoming_mail
  end

  def raw_message
    @raw_message ||= File.read raw_message_file.path
  end

  def raw_message=(new_raw_message)
    raise('Please save the record first. We need it to have an id to upload the raw message.') if new_record?
    raw_message_file.store! new_raw_message

    # If something goes wrong, this helps to find out what:
    File.exist?(raw_message_file.cache_dir) || raise("Cache directory does not exist: #{incoming_mail.raw_message.cache_dir}.")
    File.exist?(raw_message_file.store_dir) || raise("Storage directory does not exist: #{incoming_mail.raw_message.store_dir}.")
    raw_message_file.path || raise('Upload did not work.')
    File.file?(raw_message_file.path) || raise('Upload did not work. File does not exist.')

    return raw_message_file
  end

  def in_reply_to
    self.class.where(message_id: in_reply_to_message_id)
  end

  def destinations
    if envelope_to
      envelope_to.split(",").map(&:strip)
    else
      (to.to_s.split(",") + cc.to_s.split(",")).map(&:strip)
    end
  end
  def destination
    raise "No destinations." if destinations.count == 0
    raise "The envelope contains several recipients: #{destinations.join(', ')}" if destinations.count > 1
    destinations.first
  end

  def sender_user
    sender_profileable if sender_profileable.kind_of? User
  end
  def sender_profileable
    ProfileFieldTypes::Email.where(value: from).first.try(:profileable)
  end

  def recipient_group
    recipient_profileable if recipient_profileable.kind_of? Group
  end
  def recipient_profileable
    ProfileFieldTypes::MailingListEmail.where(value: destination).first.try(:profileable)
  end

  def authorized?
    recipient_group || raise('Cannot determine recipient group.')
    Ability.new(sender_user).can? :create_post_for, recipient_group
  end

  def self.load_subclasses
    IncomingMails::GroupMailingListMail
    IncomingMails::MailWithoutAuthorization
    IncomingMails::PostMail
    IncomingMails::TestMail
    return subclasses
  end
  def process(options = {})
    self.class.load_subclasses
    self.class.subclasses.collect do |incoming_mail_subclass|
      if options[:async] and Rails.env.production?
        incoming_mail_subclass.delay.process id
      else
        incoming_mail_subclass.process id
      end
    end.flatten
  end

  # options:
  #   - async: whether to process the independent steps
  #            asynchronously through sidekiq.
  #
  def self.process(id, options = {})
    find(id).process(options)
  end

end