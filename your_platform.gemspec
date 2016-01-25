$:.push File.expand_path("../lib", __FILE__)

# SEE ALSO
# https://github.com/fiedl/your_platform/blob/master/your_platform.gemspec

# Maintain your gem's version:
require "your_platform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "your_platform"
  s.version     = YourPlatform::VERSION

  s.authors     = [ "Sebastian Fiedlschuster" ]
  s.email       = [ "sebastian@fiedlschuster.de" ]
  s.homepage    = "https://github.com/fiedl/your_platform"

  s.summary     = "Administrative and social network platform for closed user groups."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  # Dependencies 
  # --------------------------------------------------------------------------------

  # Rails and Rails Additions
  s.add_dependency "rails", ">= 4.2.2"
  s.add_dependency 'rack', '>= 1.6.2'
  s.add_dependency 'rack-ssl', '>= 1.3.4'
  s.add_dependency "rails-i18n"                                                        # MIT License
  s.add_dependency "responders", "~> 2.0"
  s.add_dependency "bundler", ">= 1.9.4"
  s.add_dependency 'web-console', '>= 2.1.3'
  s.add_dependency 'sprockets-rails', '~> 2.3'

  
  # JavaScript 
  s.add_dependency 'rails-assets-jquery-ujs'
  s.add_dependency "autosize-rails" # autosize textbox
  s.add_dependency "sugar-rails"
  s.add_dependency "i18n-js", '>= 3.0.0.rc8'
  s.add_dependency "coffee-rails", '>= 4.1.0'
  s.add_dependency 'execjs', '>= 2.5.2'
  s.add_dependency 'jquery-atwho-rails', '>= 1.1.0' # @mentions
  s.add_dependency 'rails-assets-jquery-ui'
  s.add_dependency 'turbolinks', '>= 2.5.3'
  s.add_dependency 'jquery-turbolinks'
  s.add_dependency 'turboboost'
  s.add_dependency 'rails-assets-datatables', '>= 1.10.10'

  # Data Structures
  # Retry transactions: Rescue from deadlocks.
  s.add_dependency 'transaction_retry'
  # DAG Structure, https://github.com/resgraph/acts-as-dag
  s.add_dependency 'acts-as-dag', '>= 2.5.7'                                           # MIT License
  s.add_dependency 'acts_as_tree'                                                      # MIT License
  
  # Caching
  s.add_dependency 'redis-rails'
  
  # Workers
  s.add_dependency 'foreman'
  s.add_dependency 'sidekiq', '>= 3.4.2'
  s.add_dependency 'sidekiq-limit_fetch'
  

  # Authentification
  s.add_dependency 'devise', '>= 2.2.5'                           # MIT License
  s.add_dependency 'passgen'

  # Authorization
  s.add_dependency 'cancan'                                                            # MIT License

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt', '>= 3.0.1'                                                # MIT License 

  # Settings
  s.add_dependency 'rails-settings-cached'

  # Template Engines
  # haml template language, http://haml.info
  s.add_dependency 'haml'                                                              # MIT License
  s.add_dependency 'redcarpet', '>= 3.3.2'  # for Markdown                             # MIT License
  s.add_dependency 'gemoji', '>= 2.1.0'
  s.add_dependency 'auto_html', '~> 1.6.4'
  
  # Layout: Twitter Bootstrap
  s.add_dependency 'font-awesome-rails', '~> 4.3.0'
  # fix bootstrap to 3.3.3 due to icon issue:
  s.add_dependency 'bootstrap-sass', '= 3.3.3'                                                  # Apache License 2.0
  s.add_dependency 'sass-rails', '>= 3.2'

  # In Place Editing
  s.add_dependency 'best_in_place', '>= 2.1.0'                                         # MIT License
  
  # Geo Coding
  s.add_dependency 'geocoder'                                                          # MIT License
  s.add_dependency 'gmaps4rails', '2.0.2' # CURRENTLY ONLY THE FORK WORKS FOR US       # MIT License
  s.add_dependency 'biggs'

  # Formtastic Form Helper
  s.add_dependency 'formtastic'  # MIT License

  # File Uploads
  s.add_dependency 'carrierwave'                                                       # MIT License
  s.add_dependency 'mini_magick'
  s.add_dependency 'refile', '~> 0.5.5'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'rest-client', '>= 1.8'

  # Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
  s.add_dependency 'gravatar_image_tag'                                                # MIT License

  # Edit Mode
  s.add_dependency 'edit_mode', '>= 1.0.2'                                             # MIT License

  # Hide slim breadcrumb elements until user hovers the separator
  s.add_dependency 'slim_breadcrumb', '>= 0.0.3'                                       # MIT License
  
  # View Helpers
  s.add_dependency 'phony'                                         
  s.add_dependency 'will_paginate', '> 3.0'
  
  # Client-Side Validations
  s.add_dependency 'judge'
  
  # Metrics
  s.add_dependency 'fnordmetric'                                                       # MIT License
  s.add_dependency 'rack-mini-profiler', '>= 0.9.0.pre'                                # MIT License
  
  # Activity Feed
  s.add_dependency 'public_activity', '~> 1.4.1'                                       # MIT License
  
  # XLS Export
  s.add_dependency 'to_xls'
  
  # PDF Export
  s.add_dependency 'prawn'
  
  # ICS Export (iCal)
  s.add_dependency 'icalendar'
  
  # Gamification
  s.add_dependency 'merit'
  
  # Dummy Data Generation
  s.add_dependency 'faker'
  
  # Fixes
  # https://github.com/eventmachine/eventmachine/issues/509
  s.add_dependency 'eventmachine', '>= 1.0.7'
  # https://github.com/lautis/uglifier/pull/86
  s.add_dependency 'uglifier', '>= 2.7.2'
  s.add_dependency 'mail', '>= 2.6.0' # https://gemnasium.com/fiedl/your_platform/alerts#advisory_309
  s.add_dependency 'nokogiri', '>= 1.6.7.1' # https://gemnasium.com/fiedl/your_platform/alerts#advisory_311

  # Development Dependencies 
  # --------------------------------------------------------------------------------

  s.add_development_dependency "rspec-rails", "2.10.0"
  s.add_development_dependency "guard", "1.0.1"
  s.add_development_dependency "guard-rspec", "0.5.5"

end