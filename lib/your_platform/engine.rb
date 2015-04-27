
# Required Gems.
# This should mirror your_platform.gemspec, as far as the gems need to be required.
#
# Gem Source
require 'rubygems'

# Rails and Additions
require 'rails-i18n'
require 'strong_parameters' unless defined? ActionController::Parameters

# JavaScript
require 'jquery-ui-rails'
require 'sugar-rails'
require 'i18n-js'

# Data Structures
require 'acts-as-dag'
require 'acts_as_tree'

# Caching
require 'redis-rails'

# Workers
require 'sidekiq'

# Authentification
require 'devise'
require 'passgen'

# Authorization
require 'cancan'

# Settings
require 'rails-settings-cached'

# Template Engines
require 'haml'
require 'redcarpet'

# Layout: Twitter Bootstrap
require 'font-awesome-rails'
require 'bootstrap-sass'
require 'sass-rails'

# In Place Editing
require 'best_in_place'

# Geo Coding
require 'geocoder'
require 'gmaps4rails'

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

# Workflow Kit
require 'workflow_kit'

# View Helpers
require 'phony' 
require 'will_paginate'
require 'jquery-datatables-rails'

# JavaScript
require 'turbolinks'
require 'jquery-turbolinks'

# Client-Side Validations
require 'judge'

# Metrics
require 'fnordmetric'
require 'rack-mini-profiler'

# Activity Logger
require 'public_activity'

# PDF Export
require 'prawn'

# XLS Export
require 'to_xls'

# ICS Export (iCal)
require 'icalendar'

module YourPlatform
  class Engine < ::Rails::Engine

    engine_name "your_platform"
    
    config.autoload_paths += %W(#{config.root}/app/models/concerns)

    config.i18n.load_path += Dir[ Engine.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[ Engine.root.join('app', 'locales', '**', '*.{rb,yml}').to_s]
    
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
