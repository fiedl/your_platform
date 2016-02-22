# This model wraps information that is needed for post delivery reports,
# i.e. "when has the post successfully been sent to whom", et cetera.
#
module PostDeliveryReport
  
  def created_via_email?
    self.message_id.present? || (self.sent_via.present? && self.sent_via.include?('@'))
  end

  def created_via_contact_form?
    self.deliveries.any? and not created_via_email?
  end

  def created_via_social_messaging?
    self.notifications.any? and not created_via_contact_form?
  end

  def successfully_sent_to
    User.find successfully_sent_to_user_ids
  end 
  def successfully_sent_to_user_ids
    (self.deliveries.sent.pluck(:user_id) + self.notifications.sent.pluck(:recipient_id) + self.notifications.read.pluck(:recipient_id)).uniq
  end
  def successfully_sent_to_count
    successfully_sent_to_user_ids.count
  end
  
  def failed_to_send_to
    User.find failed_to_send_to_user_ids
  end
  def failed_to_send_to_user_ids
    self.deliveries.failed.pluck(:user_id).uniq + self.notifications.failed.pluck(:recipient_id)
  end
  def failed_to_send_to_count
    failed_to_send_to_user_ids.count
  end
  
  def pending_to_send_to
    User.find pending_to_send_to_user_ids
  end
  def pending_to_send_to_user_ids
    (self.deliveries.due.pluck(:user_id) + self.notifications.upcoming.pluck(:recipient_id)).uniq
  end
  def pending_to_send_to_count
    pending_to_send_to_user_ids.count
  end
  
  def recipients_count
    @recipients_count ||= (successfully_sent_to_user_ids + failed_to_send_to_user_ids + pending_to_send_to_user_ids).uniq.count
  end
  
  # Some posts are too old: There is not enough information to reconstruct the deliveries.
  # In those cases, do not show the deliveries. Otherwise "0 recipients" would be shown,
  # which is misleading.
  #
  def has_delivery_report?
    (recipients_count > 0) || sent_via.present?
  end
  
end