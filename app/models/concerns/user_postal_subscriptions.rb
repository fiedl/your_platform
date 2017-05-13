concern :UserPostalSubscriptions do

  included do
    delegate :local_postal_mail_subscribed_at, :local_postal_mail_subscribed_at=, to: :settings
  end

  def local_postal_mail_subscription
    local_postal_mail_subscribed_at && true || false
  end

  def local_postal_mail_subscription=(activate_subscription)
    if activate_subscription == true || activate_subscription == "true"
      self.local_postal_mail_subscribed_at = Time.zone.now
    else
      self.local_postal_mail_subscribed_at = nil
    end
  end

  class_methods do
    def with_local_postal_mail_subscription
      self.with_settings
          .where(settings: {thing_type: 'User', var: 'local_postal_mail_subscribed_at'})
          .where('settings.thing_id = users.id AND CHAR_LENGTH(settings.value) > 10')
    end
  end

end