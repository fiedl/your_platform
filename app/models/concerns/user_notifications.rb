concern :UserNotifications do
  
  included do
    has_many :notifications, foreign_key: 'recipient_id'
    
    after_create { self.update_attribute :notification_policy, :letter_bundle }
  end
  
  # Notification Policy of the user:
  # 
  #    * :daily                         Deliver the notifications once a day.
  #    * :letter_bundle                 Deliver as letter bundle, i.e. when some
  #                                       notifications are collected and nobody
  #                                       contributed for 15 minutes.
  #    * :instantly                     Deliver all notifications without delay.
  #
  def notification_policy
    super.try(:to_sym)
  end
  def notification_policy_possible_settings
    [:daily, :letter_bundle, :instantly]
  end
  
  # Later, we can use this for a personal greeting.
  #
  def greeting
    if Time.zone.now > "4:00".to_time and Time.zone.now < "11:00".to_time
      I18n.t(:good_morning, locale: locale)
    elsif Time.zone.now > "11:00".to_time and Time.zone.now < "17:00".to_time
      I18n.t(:good_day, locale: locale)
    else
      I18n.t(:good_evening, locale: locale)
    end
  end
  
end