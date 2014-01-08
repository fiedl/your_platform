
# Required Gems.
# This should mirror your_platform.gemspec, as far as the gems need to be required.
#
# Gem Source
require 'rubygems'

# Rails and Additions
require 'rails-i18n'
require 'strong_parameters'

# JavaScript

# Data Structures
require 'acts-as-dag'
require 'acts_as_tree'

# Authentification
require 'devise'

# Authorization
require 'cancan'

# Template Engines
require 'haml'
require 'redcarpet'

# Layout: Twitter Bootstrap
require 'twitter-bootstrap-rails'
require 'less'
require 'less-rails'
require 'font-awesome-rails'

# In Place Editing
require 'best_in_place'

# Geo Coding
require 'geocoder'
require 'gmaps4rails'

# File Uploads
require 'carrierwave'
require 'jquery-fileupload-rails'

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

# Gallery View
require 'rubylight'

# Metrics
require 'fnordmetric'
require 'rack-mini-profiler'

module YourPlatform
  class Engine < ::Rails::Engine

    engine_name "your_platform"

    config.i18n.load_path += Dir[ Engine.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[ Engine.root.join('app', 'locales', '**', '*.{rb,yml}').to_s]

    config.generators do |g|
      # use rspec, see: http://whilefalse.net/2012/01/25/testing-rails-engines-rspec/
      g.test_framework :rspec
      g.integration_tool :rspec
    end
  end
end
