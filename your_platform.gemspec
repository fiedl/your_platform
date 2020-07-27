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
  s.add_development_dependency 'web-console'
  s.add_dependency 'sprockets-rails', '>= 2.3.2' # required by bootstrap
  s.add_dependency 'decent_exposure'


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
  #s.add_dependency 'omniauth-github'
  #s.add_dependency 'omniauth-twitter'
  #s.add_dependency 'omniauth-google-oauth2'
  #s.add_dependency 'omniauth-facebook', '~> 3.0.0'
  # omniauth dropped due to CVE-2015-9284
  # https://github.com/fiedl/your_platform/network/alert/demo_app/my_platform/Gemfile.lock/omniauth/open
  # https://github.com/omniauth/omniauth/issues/960
  # https://github.com/omniauth/omniauth/pull/809

  s.add_dependency 'devise_masquerade', '~> 0.5.3'
  s.add_dependency 'gender_detector'
  s.add_dependency 'devise_token_auth', '1.1.0' # 1.1.1 introduces an issue with `authenticate_api_v1_user_account!`, https://trello.com/c/p7kSJGz5/1398-app-funktioniert-nicht-mehr-access-control-origin#comment-5d5d65e117444351197bea4e
  s.add_dependency 'rack-cors'

  # Authorization
  s.add_dependency 'cancancan', '~> 1.15.0'

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt', '>= 3.0.1'                                                # MIT License

  # Settings
  s.add_dependency 'rails-settings-cached', '>= 0.6.5'

  # Template Engines
  s.add_dependency 'haml', '~> 4.0' # NameError: undefined method `precompiled_method_return_value' for class `Haml::Compiler', https://github.com/fiedl/wingolfsplattform/commit/bad4932ce2e611b2a8d7015e20dcfd18e0a376d4
  s.add_dependency 'redcarpet', '>= 3.3.2'  # for Markdown                             # MIT License
  s.add_dependency 'gemoji', '>= 2.1.0'
  s.add_dependency 'auto_html', '~> 1.6.4'
  s.add_dependency 'reverse_markdown'

  # Layout: Twitter Bootstrap
  s.add_dependency 'bootstrap', '~> 4.3.1' # https://github.com/twbs/bootstrap-rubygem
  s.add_dependency 'sass-rails'
  s.add_dependency 'sass', '>= 3.7.4' # https://github.com/twbs/bootstrap/issues/24549#issuecomment-339473607

  # In Place Editing
  s.add_dependency 'best_in_place', '>= 2.1.0'                                         # MIT License

  # Search
  s.add_dependency 'elasticsearch-model'

  # Geo Coding
  s.add_dependency 'geocoder'                                                          # MIT License
  s.add_dependency 'biggs'

  # Form Helper
  s.add_dependency 'formtastic'  # MIT License
  s.add_dependency 'simple_form', '>= 5.0.0' # GHSA-r74q-gxcg-73hx, https://trello.com/c/rX2RZtgU/1438

  # File Uploads
  s.add_dependency 'carrierwave', '~> 0.11'                                                       # MIT License
  s.add_dependency 'mini_magick', '>= 4.9.4' # CVE-2019-13574
  s.add_dependency 'refile', '>= 0.5.5'
  s.add_dependency 'jquery-fileupload-rails'
  s.add_dependency 'rest-client', '>= 1.8'

  # Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
  s.add_dependency 'gravatar_image_tag'                                                # MIT License

  # Edit Mode
  s.add_dependency 'edit_mode', '>= 1.0.5'                                             # MIT License

  # View Helpers
  s.add_dependency 'phony'
  s.add_dependency 'will_paginate', '> 3.0'
  s.add_dependency 'naturally' # natural sorting 1, 3, 12

  # Gallery
  s.add_dependency 'rails-assets-imagesloaded'
  # also, galleria is in our `vendor` directory.

  # Client-Side Validations
  s.add_dependency 'judge'

  # Metrics
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'chartkick', '>= 3.2.0' # CVE-2019-12732
  s.add_dependency 'groupdate'
  s.add_dependency 'impressionist', '~> 1.6'

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
  s.add_dependency 'faker', '~> 2.3'

  # Console
  s.add_dependency "table-formatter"

  # Contact form
  s.add_dependency 'mail_form'

  # API
  s.add_dependency 'apipie-rails', '~> 0.5'
  s.add_dependency 'discourse_api'

  # Exceptions
  s.add_dependency 'exception_notification'

  # Log
  s.add_dependency 'fiedl-log'

  # LDAP
  s.add_dependency 'net-ldap'

  # Neo4j
  s.add_dependency 'neography'

  # Trello API
  s.add_dependency 'ruby-trello'

  # Emails and Encoding
  s.add_dependency 'charlock_holmes'
  s.add_dependency 'extended_email_reply_parser'


  # Fixes
  # https://github.com/eventmachine/eventmachine/issues/509
  s.add_dependency 'eventmachine', '>= 1.0.7'
  # https://github.com/lautis/uglifier/pull/86
  s.add_dependency 'uglifier', '>= 2.7.2'
  s.add_dependency 'mail', '~> 2.6.6.rc1' # https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_309
  s.add_dependency 'nokogiri', '>= 1.10.4' # CVE-2019-5477, https://trello.com/c/whoVKwMA/1394
  s.add_dependency 'actionpack', '>= 4.2.5.2' # CVE-2016-2098, https://gemnasium.com/fiedl/your_platform/alerts#advisory_342
  s.add_dependency 'activerecord', '>= 4.2.7.1' # CVE-2016-6317, https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_426
  s.add_dependency 'rubyzip', '>= 1.3.0'  # CVE-2019-16892, https://trello.com/c/2dzbwn2f/1439
  s.add_dependency 'actionview', '>= 5.0.7.2'  # CVE-2019-5418, https://trello.com/c/4sVtIW7h/1330-kritische-sicherheitslücke-in-actionview-cve-2019-5418
  s.add_dependency 'yard', '>= 0.9.20' # GHSA-xfhh-rx56-rxcr

  #
  # Development Dependencies
  #

  s.add_development_dependency "rspec-rails"

  # Email preview
  s.add_development_dependency "letter_opener"
  s.add_development_dependency "letter_opener_web"

end
