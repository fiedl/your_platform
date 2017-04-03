# global application settings:
#
#   * Setting.app_name
#   * Setting.preferred_locale
#   * Setting.support_email
#
class Setting < RailsSettings::Base
  def self.app_name=(name)
    super(name)
    Rails.cache.delete_matched 'app_version_footer*'
  end

  def self.preferred_locale
    return nil if super == ""
    super
  end

  def self.support_email
    if super.present?
      super
    else
      logger.warn('No support email address (support@example.com) set. Please set it using the Setting.support_email accessor.')
      return "support@example.com"
    end
  end
end
