concern :UserNotifications do
  
  # Notification Policy of the user:
  # 
  #    * :daily           (default)     Deliver the notifications once a day.
  #    * :letter_bundle                 Deliver as letter bundle, i.e. when some
  #                                       notifications are collected and nobody
  #                                       contributed for 15 minutes.
  #    * :instantly                     Deliver all notifications without delay.
  #
  def notification_policy
    super || :daily
  end
  def notification_policy_possible_settings
    [:daily, :letter_bundle, :instantly]
  end
  
  # The preferred locale of the user, which can be set through
  # the user settings or the page footer.
  #
  def locale
    super || Setting.preferred_locale || I18n.default_locale
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