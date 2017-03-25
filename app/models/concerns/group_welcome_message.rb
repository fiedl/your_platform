concern :GroupWelcomeMessage do

  included do
    delegate :welcome_message, :welcome_message=, to: :settings

    alias_method :assign_user_before_welcome_message, :assign_user
    def assign_user(user, options = {})
      trigger_welcome_messages_for(user) if Rails.env.test? or (not Rails.console? and not Rails.rake_task?)
      assign_user_before_welcome_message(user, options)
    end
  end

  def trigger_welcome_messages_for(user)
    ([self] + self.ancestor_groups)
    .select { |group| not user.member_of? group, at: 10.seconds.ago }
    .each { |group| group.send_welcome_message_to user }
  end

  def send_welcome_message_to(user)
    if welcome_message.present?
      notification = user.notifications.build
      notification.reference = self
      I18n.with_locale(user.locale) do
        notification.message = I18n.t(:welcome_to_the_group_xyz, xyz: self.name)
        notification.text = welcome_message
      end
      notification.save
      return notification
    end
  end

end