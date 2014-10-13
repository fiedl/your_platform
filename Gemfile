# -*- coding: utf-8 -*-

                                                                                           # Licenses
                                                                                           # =======================================

source 'https://rubygems.org'						                                                   # Ruby License,
                                                                                           # http://www.ruby-lang.org/en/LICENSE.txt



gem 'rails', '~> 3.2'						# MIT License,
    	     								# http://www.opensource.org/licenses/mit-license.php

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'								# MIT License

# Gems used only for assets and not required
# in production environments by default.
group :assets, :production, 'testing-aki' do
  gem 'sass-rails',   '>= 3.2.3'					# MIT License
  gem 'coffee-rails', '>= 3.2.1'					# MIT License
#  gem 'coffee-script', '1.4.0' # need this at 1.4.0 for mercury, at the moment
    # see https://github.com/jejacks0n/mercury/issues/349

  gem 'uglifier', '>= 1.0.3'						# MIT License

end

# See https://github.com/sstephenson/execjs#readme for more
# supported runtimes.
# This is also needed by twitter-bootstrap-rails in production.
gem 'execjs'
# But therubyracer apparently uses a lot of memory:
# https://github.com/seyhunak/twitter-bootstrap-rails/issues/336
gem 'therubyracer', :platform => :ruby

gem 'jquery-rails'							# MIT License

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# HTML-Nodes
gem 'nokogiri'								# MIT License

# GoogleMaps
# moved dependency to your_platform.
# for turbolinks experiments, use this:
#   gem 'gmaps4rails', '>= 2.0.0.pre', git: 'https://github.com/fiedl/Google-Maps-for-Rails.git'

# jQuery UI
gem 'jquery-ui-rails'							# dual: MIT License, GPL2 License

# DAG für Nodes Model, see: https://github.com/resgraph/acts-as-dag
#gem 'acts-as-dag', path: '../acts-as-dag'
#gem 'acts-as-dag', git: "git://github.com/resgraph/acts-as-dag.git"	# MIT License
#gem 'acts-as-dag', '>= 2.5.7'  # now in your_platform

# Formtastic Form Helper,
# see: https://github.com/justinfrench/formtastic,
# http://rubydoc.info/gems/formtastic/frames
gem 'formtastic'							# MIT License

# JSON
gem 'json'								# Ruby License

# Lucene
# gem 'lucene'								# MIT License

# Farbiger Konsolen-Output
gem 'colored'								# MIT License

# Auto Completion
#gem 'rails3-jquery-autocomplete'					# MIT Licenses

# Debug Tools
group :development do

  # debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
  #gem 'debugger'

  gem 'better_errors'              # see Railscasts #402
  gem 'binding_of_caller'
  gem 'meta_request'
  
  gem 'letter_opener'
end

# Security Tools
group :development, :test do
  gem 'brakeman', '>= 2.3.1'
  gem 'guard-brakeman', '>= 0.8.1'
end

# Documentation Tools
group :development, :test do
  gem 'yard'
  gem 'redcarpet'
end

# RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
group :test, :development do
  gem 'guard', '~> 2.2.5'
  gem 'guard-focus'
  gem 'rspec-rails'
  gem 'guard-rspec'
#  gem 'rspec-mocks'
#  gem 'listen'
#  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
end
group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
  gem 'database_cleaner'
  gem 'guard-spork'
  gem 'spork'
  gem 'simplecov', require: false
  gem 'timecop'  # time_travel
  gem 'fuubar' # better progress bar for specs
end

group :test do
  gem 'poltergeist', '1.5.0'
end

# Automatische Anzeige des Red-Green-Refactor-Zyklus.
# Packages: see: http://ruby.railstutorial.org/chapters/static-pages
# Diese Pakete scheinen nicht mehr notwendig zu sein und vielmehr Guard zum Absturz zu bringen (SF 2012-06-06)
#group :test do
#  if RUBY_PLATFORM.downcase.include?("linux")
#    gem 'rb-inotify' #, '0.8.8'
#    gem 'libnotify' #, '0.5.9'
#  end
#  if RUBY_PLATFORM.downcase.include?("darwin") # Mac
#    gem 'rb-fsevent', :require => false
#    gem 'growl'
#  end
#  if RUBY_PLATFORM.downcase.include?("windows")
#   gem 'rb-fchange'
#    gem 'rb-notifu'
#    gem 'win32console'
#  end
#end


# password generator. it's not pwgen, but it's a gem.
# TODO: if we ever find a way to properly include pwgen, let's do it.
gem 'passgen'                                                           # MIT License

# YourPlatform
gem 'your_platform', path: 'vendor/engines/your_platform'

# Pry Console Addon
gem 'pry', group: :development

# Turbolinks
gem 'turbolinks', '>= 1.0'

# Angular JS
gem 'angularjs-rails'

# Receiving Mails
gem 'mailman', require: false
gem 'mail', git: 'git://github.com/jeremy/mail.git'
gem 'rb-inotify', '~> 0.9', group: :production

# View Helpers
# gem 'rails-gallery', git: 'https://github.com/kristianmandrup/rails-gallery'

# Encoding Detection
gem 'charlock_holmes'

# Manage Workers
gem 'foreman', group: [:development, :production]

# CMS: Mercury Editor
gem 'mercury-rails', git: 'git://github.com/jejacks0n/mercury'

# readline (for rails console)
# see https://github.com/luislavena/rb-readline/issues/84#issuecomment-17335885
#gem 'rb-readline', '~> 0.5.0', group: :development, require: 'readline'

gem 'gmaps4rails', '~> 2.0.1', git: 'git://github.com/fiedl/Google-Maps-for-Rails.git'

# To customly set timeout time we need rack-timeout
gem 'rack-timeout'

# Metrics
gem 'fnordmetric'

# Profiling
gem 'rack-mini-profiler'
gem 'flamegraph'

# Code Coverage Badge, coveralls.io
gem 'coveralls', require: false

# Temporary Dependency Resolving
# TODO Remove when obsolete
gem 'tilt', '~> 1.4.1'

# Maintenance Mode
gem 'turnout'


# fix workflow kit until the update to rails 4.
# workflow_kit 0.0.8 only supports rails 4.
# TODO: remove this line when migrating to rails 4:
gem 'workflow_kit', github: 'fiedl/workflow_kit'

gem 'newrelic_rpm'
gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'
gem 'prawn', github: 'prawnpdf/prawn'
