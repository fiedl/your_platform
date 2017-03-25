
# Required Gems.
# This should mirror your_platform.gemspec, as far as the gems need to be required.
#
# Gem Source
require 'rubygems'

# Rails and Additions
require 'sprockets'
require 'strong_parameters' unless defined? ActionController::Parameters
require 'rails-i18n'
require 'decent_exposure'

# Data Structures
require 'acts-as-dag'
require 'acts_as_tree'
require 'wannabe_bool'
require 'acts-as-taggable-on'

# Caching
require 'redis-rails'
require 'redis-namespace'

# Workers
require 'sidekiq'
require 'sidekiq-limit_fetch'

# Authentification
require 'devise'
require 'passgen'
require 'omniauth-github'
require 'omniauth-twitter'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'

# Authorization
require 'cancancan'

# Encryption
require 'has_secure_token'

# Settings
require 'rails-settings-cached'

# Template Engines
require 'haml'
require 'redcarpet'
require 'gemoji'
require 'auto_html'

# JavaScript
require 'rails-assets-jquery-ujs'
require 'rails-assets-jquery-ui'
require 'autosize/rails'
require 'sugar-rails'
require 'i18n-js'
require 'jquery-atwho-rails'
require 'jquery-turbolinks'
require 'turbolinks'
require 'turboboost'
require 'rails-assets-datatables'
require 'rails-assets-trentrichardson--jQuery-Timepicker-Addon'
require 'bootstrap_tokenfield_rails'
require 'rails-assets-inline-attachment'

# Layout: Twitter Bootstrap
require 'font-awesome-rails'
require 'bootstrap-sass'
require 'sass-rails'
require 'rails-assets-bootstrap-social'

# In Place Editing
require 'best_in_place'

# Search
require 'elasticsearch/model'

# Geo Coding
require 'geocoder'
require 'gmaps4rails'
require 'biggs'

# Form Helpers
require 'formtastic'
require 'simple_form'

# File Uploads
require 'carrierwave'
require 'jquery-fileupload-rails'
require 'refile/rails'
require 'refile/image_processing'

# Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
require 'gravatar_image_tag'

# Edit Mode
require 'edit_mode'

# View Helpers
require 'phony'
require 'will_paginate'

# Client-Side Validations
require 'judge'

# Metrics
require 'rack-mini-profiler'
require 'redis_analytics'
require 'chartkick'
require 'groupdate'

# Activity Logger
require 'public_activity'

# PDF Export
require 'prawn'

# XLS Export
require 'to_xls'

# ICS Export (iCal)
require 'icalendar'
require 'icalendar/tzinfo'

# VCF Export
require 'vcardigan'

# Gamification
require 'merit'

# Dummy User Generation
require 'faker'

# Contact form
require 'mail_form'

::STAGE = "development" unless defined? ::STAGE

module YourPlatform
  class Engine < ::Rails::Engine

    engine_name "your_platform"

    config.autoload_paths += %W(#{config.root}/app/models/concerns)
    config.autoload_paths += %W(#{config.root}/app/pdfs)

    # In order to override the locales in the main_app, add the following to the main app's
    # config/initializers/locale.rb:
    #
    #     Rails.application.config.i18n.load_path +=
    #       Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    #
    config.i18n.load_path += Dir[Engine.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    # You can override this in your app's config/application.rb.
    # But adding locales makes only sense if you add additional locales to the your_platform engine.
    #
    config.i18n.available_locales = [:de, :en]
    config.i18n.default_locale = :en

    config.generators do |g|
      # use rspec, see: http://whilefalse.net/2012/01/25/testing-rails-engines-rspec/
      g.test_framework :rspec
      g.integration_tool :rspec
    end
  end
end
