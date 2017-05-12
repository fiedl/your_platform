concern :UserPostalSubscriptions do

  included do
    delegate :corporations_postal_mail_subscribed_at, :corporations_postal_mail_subscribed_at=, to: :settings
  end

  def corporations_postal_mail_subscription
    corporations_postal_mail_subscribed_at
  end

  def corporations_postal_mail_subscription=(activate_subscription)
    if activate_subscription
      self.corporations_postal_mail_subscribed_at = Time.zone.now
    else
      self.corporations_postal_mail_subscribed_at = nil
    end
  end

  class_methods do
    def with_corporations_postal_mail_subscription
      self.with_settings
          .where(settings: {thing_type: 'User', var: 'corporations_postal_mail_subscribed_at'})
          .where('settings.thing_id = users.id AND CHAR_LENGTH(settings.value) > 10')
    end
  end

end