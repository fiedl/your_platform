# -*- coding: utf-8 -*-

									# Licenses
									# =======================================

source 'https://rubygems.org'						# Ruby License,
       									# http://www.ruby-lang.org/en/LICENSE.txt



gem 'rails', '~> 3.2.11'						# MIT License,
    	     								# http://www.opensource.org/licenses/mit-license.php

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
end

gem 'mysql2'								# MIT License

# Gems used only for assets and not required
# in production environments by default.
group :assets, :production, 'testing-aki' do
  gem 'sass-rails',   '~> 3.2.3'					# MIT License
  gem 'coffee-rails', '~> 3.2.1'					# MIT License

  gem 'uglifier', '>= 1.0.3'						# MIT License
end

# See https://github.com/sstephenson/execjs#readme for more 
# supported runtimes.
# This is also needed by twitter-bootstrap-rails in production.
gem 'execjs'
gem 'therubyracer', :platform => :ruby

# haml template language, http://haml.info
gem 'haml'

gem 'jquery-rails'							# MIT License

# To use ActiveModel has_secure_password (password encryption)
gem 'bcrypt-ruby', '>= 3.0.1'	                                        # MIT License

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# HTML-Nodes
gem 'nokogiri'								# MIT License

# i18n
gem 'rails-i18n'							# MIT License

# GoogleMaps
gem 'gmaps4rails', '~> 1.4.8'					        # MIT License

# GeoCoder
gem 'geocoder'								# 

# jQuery UI
gem 'jquery-ui-rails'							# dual: MIT License, GPL2 License 

# DAG für Nodes Model, see: https://github.com/resgraph/acts-as-dag
#gem 'acts-as-dag', path: '../acts-as-dag'
#gem 'acts-as-dag', git: "git://github.com/resgraph/acts-as-dag.git"	# MIT License
gem 'acts-as-dag', '>= 2.5.7'

# Tree-Verhalten, z.B. für Profilfelder
gem 'acts_as_tree'							# MIT License

# Formtastic Form Helper, 
# see: https://github.com/justinfrench/formtastic, 
# http://rubydoc.info/gems/formtastic/frames
gem 'formtastic'							# MIT License

# In Place Editing
gem 'best_in_place' #, git: 'git://github.com/bernat/best_in_place.git'	# MIT License
#gem 'best_in_place', path: '../best_in_place/'

# JSON
gem 'json'								# Ruby License

# Lucene
# gem 'lucene'								# MIT License

# Farbiger Konsolen-Output					
gem 'colored'								# MIT License

# Auto Completion
gem 'rails3-jquery-autocomplete'					# MIT Licenses

# Deployment with Capistrano.                                          
# Capistrano runs locally, not on the remote server.
group :development do
  gem 'capistrano' #, '~>2.11.2'
  gem 'capistrano_colors'
  gem 'net-ssh', '2.4.0'
end 

# Debug Tools
group :development do
  gem 'better_errors'              # see Railscasts #402               
  gem 'binding_of_caller'
  gem 'meta_request'
end

# RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
group :test, :development do
  gem 'guard', '1.0.1'
  gem 'guard-focus'
  gem 'rspec-rails', '2.10.0'
  gem 'guard-rspec', '0.5.5'
  gem 'rspec-mocks'
#  gem 'listen'
#  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
end
group :test do
  gem 'capybara' #, '1.1.2'
  gem 'launchy'
  gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
  gem 'database_cleaner'
#  gem 'guard-spork'
#  gem 'spork'
end

# This is for testing on wingolfsplattform.org -- since travis-pro has expired.
group :test do
  gem 'sqlite3'
#  gem 'headless'
  gem 'poltergeist'
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


# Edit-Mode, SF
gem 'edit_mode', '>= 0.0.6'                                             # MIT License
#gem 'edit_mode', path: '../edit_mode'

# hide slim breadcrumb elements until user hovers the separator, SF
gem 'slim_breadcrumb', '>= 0.0.2'                                       # MIT License

# make dag links paranoid, i.e. don't delete links, but only mark as deleted.
gem 'rails3_acts_as_paranoid'
gem 'acts_as_paranoid_dag'                                              # MIT License

# password generator. it's not pwgen, but it's a gem.
# TODO: if we ever find a way to properly include pwgen, let's do it.
gem 'passgen'                                                           # MIT License

# Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
gem 'gravatar_image_tag'                                                # MIT License

# WorkflowKit, SF
gem 'workflow_kit', '>= 0.0.4.alpha' # git: 'git://github.com/fiedl/workflow_kit.git'      # MIT License

# Twitter Bootstrap Layout
gem 'twitter-bootstrap-rails'
gem 'less', '>=2.2.2'
gem 'less-rails'
#gem 'bootstrap-sass'                                                    # Apache License 2.0

# YourPlatform
gem 'your_platform', path: 'vendor/engines/your_platform'

# LightBox 2 Gallery
#gem 'rubylight', git: 'https://github.com/Mario1988/rubylight.git'      # Creative Commons 2.5
gem 'rubylight', '>= 1.0.3.2'
# TODO: Move to *gemspec, when changes pulled into original gem.    

# Phone Number Formatting
gem 'phony'

# Pry Console Addon
gem 'pry', group: :development
