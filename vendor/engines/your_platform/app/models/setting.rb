class Setting < RailsSettings::CachedSettings
	attr_accessible :var

  def self.app_name=(name)
    super(name)
    Rails.cache.delete_matched 'app_version_footer*'
  end
  
end
