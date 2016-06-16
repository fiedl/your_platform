
# Required Gems.
# This should mirror your_platform.gemspec, as far as the gems need to be required.
#
# Gem Source
require 'rubygems'

# Rails and Additions
require 'sprockets'
require 'strong_parameters' unless defined? ActionController::Parameters
require 'rails-i18n'

# Data Structures
require 'acts-as-dag'
require 'acts_as_tree'

# Caching
require 'redis-rails'

# Workers
require 'sidekiq'
require 'sidekiq-limit_fetch'

# Authentification
require 'devise'
require 'passgen'
require 'omniauth-github'

# Authorization
require 'cancan'

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
require 'turbolinks'
require 'jquery-turbolinks'
require 'turboboost'
require 'rails-assets-datatables'

# Layout: Twitter Bootstrap
require 'font-awesome-rails'
require 'bootstrap-sass'
require 'sass-rails'
require 'rails-assets-bootstrap-social'

# In Place Editing
require 'best_in_place'

# Geo Coding
require 'geocoder'
require 'gmaps4rails'
require 'biggs'

# Form Helpers
require 'formtastic'

# File Uploads
require 'carrierwave'
require 'jquery-fileupload-rails'
require 'refile/rails'
require 'refile/image_processing'

# Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
require 'gravatar_image_tag'

# Edit Mode
require 'edit_mode'

# Hide slim breadcrumb elements until user hovers the separator
require 'slim_breadcrumb'

# View Helpers
require 'phony'
require 'will_paginate'

# Client-Side Validations
require 'judge'

# Metrics
require 'rack-mini-profiler'
require 'redis_analytics'

# Activity Logger
require 'public_activity'

# PDF Export
require 'prawn'

# XLS Export
require 'to_xls'

# ICS Export (iCal)
require 'icalendar'
require 'icalendar/tzinfo'

# Gamification
require 'merit'

# Dummy User Generation
require 'faker'

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
