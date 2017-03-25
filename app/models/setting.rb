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
end
