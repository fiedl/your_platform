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

  #
  # Dependencies
  #

  # Rails and Rails Additions
  s.add_dependency "rails", "~> 5.0.0"
  s.add_dependency 'rack', '>= 1.6.2'
  s.add_dependency 'rack-ssl', '>= 1.3.4'
  s.add_dependency "rails-i18n"                                                        # MIT License
  s.add_dependency "responders", "~> 2.0"
  s.add_dependency "bundler", ">= 1.9.4"
  s.add_dependency 'web-console'
  s.add_dependency 'sprockets-rails', '~> 2.3'
  s.add_dependency 'decent_exposure', '~> 3.0'


  # JavaScript
  s.add_dependency 'jquery-rails'
  s.add_dependency "autosize-rails" # autosize textbox
  s.add_dependency "sugar-rails"
  s.add_dependency "i18n-js", '>= 3.0.0.rc8'
  s.add_dependency "coffee-rails", '>= 4.1.0'
  s.add_dependency 'execjs', '>= 2.5.2'
  s.add_dependency 'jquery-atwho-rails', '>= 1.1.0' # @mentions
  s.add_dependency 'rails-assets-jquery-ui'
  s.add_dependency 'turbolinks', '>= 5.0'
  s.add_dependency 'jquery-turbolinks'
  s.add_dependency 'turboboost'
  s.add_dependency 'rails-assets-trentrichardson--jQuery-Timepicker-Addon', '>= 1.6.3'
  s.add_dependency 'bootstrap_tokenfield_rails'
  s.add_dependency 'rails-assets-inline-attachment'

  # Data Structures
  # Retry transactions: Rescue from deadlocks.
  s.add_dependency 'transaction_retry'
  # DAG Structure, https://github.com/resgraph/acts-as-dag
  s.add_dependency 'acts-as-dag', '>= 4.0'
  s.add_dependency 'acts_as_tree'                                                      # MIT License
  s.add_dependency 'wannabe_bool'
  s.add_dependency 'acts-as-taggable-on', '~> 4.0'

  # Caching
  s.add_dependency 'redis', '>= 3.3.3'
  s.add_dependency 'redis-rails'
  s.add_dependency 'redis-namespace'

  # Workers
  s.add_dependency 'foreman'
  s.add_dependency 'sidekiq', '~> 4.0'

  # Authentification
  s.add_dependency 'devise', '>= 3.5.4'                           # MIT License, CVE-2015-8314, https://gemnasium.com/fiedl/your_platform/alerts#advisory_329
  s.add_dependency 'passgen'
  s.add_dependency 'omniauth-github'
  s.add_dependency 'omniauth-twitter'
  s.add_dependency 'omniauth-google-oauth2'
  s.add_dependency 'omniauth-facebook', '~> 3.0.0'
  s.add_dependency 'devise_masquerade'
  s.add_dependency 'gender_detector'

  # Authorization
  s.add_dependency 'cancancan', '~> 1.15.0'

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt', '>= 3.0.1'                                                # MIT License
  s.add_dependency 'has_secure_token' # TODO: This is included in Rails 5. Remove this when migrating to Rails 5.

  # Settings
  s.add_dependency 'rails-settings-cached', '>= 0.6.5'

  # Template Engines
  s.add_dependency 'haml', '~> 4.0' # NameError: undefined method `precompiled_method_return_value' for class `Haml::Compiler', https://github.com/fiedl/wingolfsplattform/commit/bad4932ce2e611b2a8d7015e20dcfd18e0a376d4
  s.add_dependency 'redcarpet', '>= 3.3.2'  # for Markdown                             # MIT License
  s.add_dependency 'gemoji', '>= 2.1.0'
  s.add_dependency 'auto_html', '~> 1.6.4'
  s.add_dependency 'reverse_markdown'

  # Layout: Twitter Bootstrap
  s.add_dependency 'font-awesome-rails', '>= 4.7'
  # fix bootstrap to 3.3.3 due to icon issue:
  s.add_dependency 'bootstrap-sass'                                                  # Apache License 2.0
  s.add_dependency 'sass-rails'
  s.add_dependency 'rails-assets-bootstrap-social'

  # In Place Editing
  s.add_dependency 'best_in_place', '>= 2.1.0'                                         # MIT License

  # Search
  s.add_dependency 'elasticsearch-model'

  # Geo Coding
  s.add_dependency 'geocoder'                                                          # MIT License
  s.add_dependency 'biggs'

  # Form Helper
  s.add_dependency 'formtastic'  # MIT License
  s.add_dependency 'simple_form'

  # File Uploads
  s.add_dependency 'carrierwave', '~> 0.11'                                                       # MIT License
  s.add_dependency 'mini_magick'
  s.add_dependency 'refile', '>= 0.5.5'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'rest-client', '>= 1.8'

  # Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
  s.add_dependency 'gravatar_image_tag'                                                # MIT License

  # Edit Mode
  s.add_dependency 'edit_mode', '>= 1.0.3'                                             # MIT License

  # View Helpers
  s.add_dependency 'phony'
  s.add_dependency 'will_paginate', '> 3.0'

  # Gallery
  s.add_dependency 'rails-assets-imagesloaded'
  # also, galleria is in our `vendor` directory.

  # Client-Side Validations
  s.add_dependency 'judge'

  # Metrics
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'chartkick'
  s.add_dependency 'groupdate'

  # Activity Feed
  s.add_dependency 'public_activity', '~> 1.4.1'                                       # MIT License

  # XLS Export
  s.add_dependency 'to_xls'
  s.add_dependency 'excelinator'

  # PDF Export
  s.add_dependency 'prawn', '2.0.2' # 2.1.0 breaks layout margins

  # ICS Export (iCal)
  s.add_dependency 'icalendar'

  # VCF Export
  s.add_dependency 'vcardigan'

  # Gamification
  s.add_dependency 'merit'

  # Dummy Data Generation
  s.add_dependency 'faker'

  # Console
  s.add_dependency "table-formatter"

  # Contact form
  s.add_dependency 'mail_form'

  # API
  s.add_dependency 'apipie-rails', '~> 0.5'
  s.add_dependency 'discourse_api'

  # Exceptions
  s.add_dependency 'exception_notification'

  # Fixes
  # https://github.com/eventmachine/eventmachine/issues/509
  s.add_dependency 'eventmachine', '>= 1.0.7'
  # https://github.com/lautis/uglifier/pull/86
  s.add_dependency 'uglifier', '>= 2.7.2'
  s.add_dependency 'mail', '~> 2.6.6.rc1' # https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_309
  s.add_dependency 'nokogiri', '>= 1.7.2' # CVE-2017-5029, CVE-2016-1683, CVE-2016-1841, https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_714
  s.add_dependency 'actionpack', '>= 4.2.5.2' # CVE-2016-2098, https://gemnasium.com/fiedl/your_platform/alerts#advisory_342
  s.add_dependency 'activerecord', '>= 4.2.7.1' # CVE-2016-6317, https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_426
  s.add_dependency 'rubyzip', '>= 1.2.1'  # CVE-2017-5946, https://gemnasium.com/github.com/fiedl/wingolfsplattform/alerts#advisory_658

  #
  # Development Dependencies
  #

  s.add_development_dependency "rspec-rails"

end
