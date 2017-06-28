# See also: app/models/concerns/page_settings.rb
#
class PageSettings < RailsSettings::ScopedSettings

  # Post-process settings here.
  # ...

  def self.horizontal_nav_page_id_order
    if super.kind_of? Array
      super.map(&:to_i)
    else
      super
    end
  end

  # This is needed since best in place returns a json representation.
  def self.as_json(options = nil)
    get_all.as_json(options)
  end

  # For paths and routes:
  def self.model_name
    RailsSettings::ScopedSettings.model_name
  end

end