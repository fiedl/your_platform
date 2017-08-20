class PostDelivery < ApplicationRecord

  belongs_to :post
  belongs_to :user

  scope :sent, -> { where.not(sent_at: nil) }
  scope :failed, -> { where.not(failed_at: nil) }
  scope :due, -> { where(sent_at: nil, failed_at: nil) }

  def deliver
    if not user.has_account?
      self.comment = "User has no account."
      self.failed_at = Time.zone.now
      self.save
      return false
    end

    if user.email_does_not_work?
      self.comment = "Email does not work."
      self.user_email = user.email
      self.failed_at = Time.zone.now
      self.save
      return false
    end

    if user.has_account? and not user.email_does_not_work?
      self.user_email = user.email

      Rails.logger.info "Sending post as email to #{user.inspect} (#{user_email}) ..."
      if PostMailer.post_email(post.text, [user], post.email_subject, post.author, post.group, post).deliver_now
        self.sent_at = Time.zone.now
        self.save
        return self
      else
        self.comment = "Delivery failed."
        self.failed_at = Time.zone.now
        self.save
        return false
      end
    elsif not user.has_account?
      self.comment = "User has no account."
      self.failed_at = Time.zone.now
      self.save
      return false
    elsif user.email_does_not_work?
      self.comment = "Email does not work."
      self.failed_at = Time.zone.now
      self.save
    end
  end

  def deliver_if_due
    deliver if due?
  end

  def due?
    self.class.due.exists?(self.id)
  end

  def self.deliver_if_due(id)
    PostDelivery.find(id).deliver_if_due
  end

end
