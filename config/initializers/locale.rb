# in config/initializers/locale.rb, see: http://guides.rubyonrails.org/i18n.html
 
# tell the I18n library where to find your translations
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
 
# set default locale to something other than :en
I18n.default_locale = :de
