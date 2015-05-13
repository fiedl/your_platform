# in config/initializers/locale.rb, see: http://guides.rubyonrails.org/i18n.html

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
I18n.config.enforce_available_locales = true

# tell the I18n library where to find your translations
I18n.load_path = Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s] + Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')] + I18n.load_path
 
# set default locale to something other than :en
I18n.available_locales = [:en, :de]
I18n.default_locale = :en
I18n.locale = :en

# The locale is dynamically set in the ApplicationController of YourPlatform.
