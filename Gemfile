source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem "colored"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem "letter_opener"
  #gem "letter_opener_web"

  gem "pry"
  gem "pry-remote"
end

group :development, :test do
  gem "rspec-rails"
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'parallel_tests'
  gem 'rspec-instafail'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'timecop'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Rails and Rails Additions
gem "rails-i18n"
gem "responders"
gem 'decent_exposure'

# JavaScript
gem 'jquery-rails'
gem "sugar-rails"
gem "i18n-js", '>= 3.0.0.rc8'
gem "coffee-rails", '>= 4.1.0'
gem 'execjs', '>= 2.5.2'
gem 'json', '~> 2.3.0'

# Data Structures
# DAG Structure, https://github.com/resgraph/acts-as-dag
gem 'acts-as-dag', github: "resgraph/acts-as-dag"
gem 'acts_as_tree'
gem 'wannabe_bool'
gem 'acts-as-taggable-on'

# Caching
gem 'redis'
gem 'redis-rails'
gem 'redis-namespace'

# Workers
#gem 'foreman'
gem 'sidekiq'

# Authentification
gem 'devise', '>= 3.5.4' # CVE-2015-8314
gem 'devise_masquerade'
gem 'gender_detector'
gem 'devise_token_auth' # 1.1.1 introduces an issue with `authenticate_api_v1_user_account!`, https://trello.com/c/p7kSJGz5/1398-app-funktioniert-nicht-mehr-access-control-origin#comment-5d5d65e117444351197bea4e
gem 'rack-cors'

# Omniauth
# omniauth dropped due to CVE-2015-9284
# https://github.com/fiedl/your_platform/network/alert/demo_app/my_platform/Gemfile.lock/omniauth/open
# https://github.com/omniauth/omniauth/issues/960
# https://github.com/omniauth/omniauth/pull/809
## gem 'omniauth-github'
## gem 'omniauth-twitter'
## gem 'omniauth-google-oauth2'
## gem 'omniauth-facebook', '~> 3.0.0'

# Authorization
gem 'cancancan'

# To use ActiveModel has_secure_password (password encryption)
gem 'bcrypt'

# Settings
gem 'rails-settings-cached', '0.7.1'

# Template Engines
gem 'haml' #, '~> 4.0' # NameError: undefined method `precompiled_method_return_value' for class `Haml::Compiler', https://github.com/fiedl/wingolfsplattform/commit/bad4932ce2e611b2a8d7015e20dcfd18e0a376d4
gem 'redcarpet'
#s.add_dependency 'gemoji', '>= 2.1.0'
#s.add_dependency 'auto_html', '~> 1.6.4'
#s.add_dependency 'reverse_markdown'

# Search
gem 'elasticsearch-model'

# Geo Coding
gem 'geocoder'
gem 'biggs'

## Form Helper
#s.add_dependency 'formtastic'  # MIT License
#s.add_dependency 'simple_form', '>= 5.0.0' # GHSA-r74q-gxcg-73hx, https://trello.com/c/rX2RZtgU/1438

# File Uploads
gem 'carrierwave'
gem 'mini_magick', '>= 4.9.4' # CVE-2019-13574
gem 'refile', github: 'refile/refile', require: 'refile/rails.rb'
#gem 'refile-mini_magick', git: 'https://github.com/refile/refile-mini_magick'

# View Helpers
gem 'phony'
gem 'naturally' # natural sorting 1, 3, 12

## Client-Side Validations
#s.add_dependency 'judge'

# Metrics
#s.add_dependency 'chartkick', '>= 3.2.0' # CVE-2019-12732
#s.add_dependency 'groupdate'
#s.add_dependency 'impressionist', '~> 1.6'

# Activity Feed
gem 'public_activity'

# XLS Export
gem 'to_xls'
gem 'excelinator'

# PDF Export
gem 'prawn'

# ICS Export (iCal)
gem 'icalendar'

# VCF Export
gem 'vcardigan'

# XML Export
gem 'sepa_king'

# Gamification
gem 'merit'

# Dummy Data Generation
gem 'faker'

## Console
#s.add_dependency "table-formatter"

# Contact form
gem 'mail_form'

# API
gem 'apipie-rails'
#s.add_dependency 'discourse_api'

# Exceptions
gem 'exception_notification'

# Log
gem 'fiedl-log'

# LDAP
gem 'net-ldap'

# Neo4j
gem 'neography'

# Trello API
gem 'ruby-trello'

# Emails and Encoding
gem 'charlock_holmes'
gem 'extended_email_reply_parser'

# To customly set timeout time we need rack-timeout
gem 'rack-timeout'

# Profiling
gem 'flamegraph'
gem 'stackprof'

# Maintenance Mode
gem 'turnout'

## Fixes
## https://github.com/eventmachine/eventmachine/issues/509
#s.add_dependency 'eventmachine', '>= 1.0.7'
## https://github.com/lautis/uglifier/pull/86
#s.add_dependency 'uglifier', '>= 2.7.2'
#s.add_dependency 'mail', '~> 2.6.6.rc1' # https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_309
#s.add_dependency 'nokogiri', '>= 1.10.4' # CVE-2019-5477, https://trello.com/c/whoVKwMA/1394
#s.add_dependency 'actionpack', '>= 4.2.5.2' # CVE-2016-2098, https://gemnasium.com/fiedl/your_platform/alerts#advisory_342
#s.add_dependency 'activerecord', '>= 4.2.7.1' # CVE-2016-6317, https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_426
#s.add_dependency 'rubyzip', '>= 1.3.0'  # CVE-2019-16892, https://trello.com/c/2dzbwn2f/1439
#s.add_dependency 'actionview', '>= 5.0.7.2'  # CVE-2019-5418, https://trello.com/c/4sVtIW7h/1330-kritische-sicherheitslücke-in-actionview-cve-2019-5418
#s.add_dependency 'yard', '>= 0.9.20' # GHSA-xfhh-rx56-rxcr
#
