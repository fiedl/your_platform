#
# This file contains the configuration of our test suite.
# We are using the following tools:
# 
# RSpec             Defining test-driven or behavior-driven specifications of 
#                   software components. 
#                   http://rspec.info/
#
# rspec-rails       Integration of RSpec into Rails, providing generators, et cetera.
#                   https://github.com/rspec/rspec-rails
#
# Guard             Detecting changed files and running corresponding tests in the
#                   background during development.
#                   https://github.com/guard/guard
#
# Spork             Keeping some less frequently changing components in memory
#                   in order to increase test performance, i.e. minimize the time
#                   Guard needs to restart the tests.
#                   https://github.com/sporkrb/spork
# 
# Capybara          Simulating user interaction in order to write high level
#                   integration tests. 
#                   https://github.com/jnicklas/capybara
#
# PhantomJS         Simulated browser for running integration tests headless,
#                   including the execution of JavaScript and AJAX requests. 
#                   http://phantomjs.org/
# 
# poltergeist       Driver to use PhantomJS with Capybara.
#                   https://github.com/jonleighton/poltergeist
#
# FactoryGirls      Library to provide test data objects. 
#                   https://github.com/thoughtbot/factory_girl
# 
# SimpleCov         Tool to detect the test coverage of our code.
#                   https://github.com/colszowka/simplecov
# 
# Coveralls         Tool to add a code coverage badge.
#                   https://coveralls.io/docs/ruby
#

# Required Basic Libraries
# ==========================================================================================

# These libraries are required to load Spork. Since every test requires, i.e. loads 
# this spec helper, they are loaded separately for each test run.
# 
# In order to increase performance, loading of the other libraries takes place within
# the `Spork.prefork` block. This causes the libraries being cached in memory rather 
# than being loaded for each run separately. 
#
require 'rubygems'
require 'spork'
# uncomment the following line to use spork with the debugger
# require 'spork/ext/ruby-debug'

# To create an online coverage report on coveralls.io, 
# init their gem here.
#
require 'coveralls'
Coveralls.wear! 'rails'


# Requirements and Configurations Cached by Spork
# ==========================================================================================

# These requirements and configurations are loaded by Spork. Spork will cache them
# in memory. 
#
# Remember to restart Spork (kill and restart guard) whenever you need to reload one
# of the components. If you find yourself to often restarting guard because of this,
# you should probably move the concerning component into the `Spork.each_run` block.
#
Spork.prefork do


  # Required Application Environment
  # ----------------------------------------------------------------------------------------
  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../config/environment', __FILE__)


  # Required Libraries
  # ----------------------------------------------------------------------------------------
  
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'nokogiri'
  require 'capybara/poltergeist'
  require 'rspec/expectations'


  # Required Support Files (that help you testing)
  # ----------------------------------------------------------------------------------------

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  #Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
  Dir[Rails.root.join('vendor/engines/your_platform/spec/support/**/*.rb')].each {|f| require f}


  # SimpleCov: Code Coverage
  # ----------------------------------------------------------------------------------------

  # Resource on using SimpleCov together with Spork:
  # https://github.com/colszowka/simplecov/issues/42#issuecomment-4440284
  #
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end


  # Factories, Stubs and Mocks
  # ----------------------------------------------------------------------------------------

  # Mock objects are simplified objects ("stub") that are used rather than the 
  # real, more complex objects, e.g. in order to increase performance.
  # 
  # Rather than `rspec-mocks` fixtures, we use FactoryGirl instead.
  #
  FactoryGirl.definition_file_paths = %w(spec/factories vendor/engines/your_platform/spec/factories)

  # In order to not hit the geocoding API, we use stub data for geocoding.
  #
  Geocoder.configure( lookup: :test )
  

  # Capybara & Poltergeist  Configuration
  # ----------------------------------------------------------------------------------------

  Capybara.register_driver :poltergeist do |app|

    # The `inspector: true` argument gives you the possibility to stop the execution
    # of the tests using `page.driver.debug` in your spec code. This will open an
    # inspector in the browser that allows you to see the current DOM structure and 
    # other information useful for debugging tests.
    # 
    Capybara::Poltergeist::Driver.new(app, inspector: true)
  end
  Capybara.javascript_driver = :poltergeist
  
  # Set the time that Capybara should wait for ajax requests to be finished.
  # The default is 2 seconds.
  # 
  # See: https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends
  # 
  Capybara.default_wait_time = 15


  # Rspec Configuration
  # ----------------------------------------------------------------------------------------

  RSpec.configure do |config|

    # Inclusion of helper methods.
    # ......................................................................................
    #
    # The methods contained in the modules marked to be included here, will be 
    # available in the spec code, without being prefixed.
    #
    # For example, including the url_helpers allows to use `url_for(some_object)` 
    # in the specs.
    #
    config.include RSpec::Matchers
    config.include Rails.application.routes.url_helpers
    config.include FactoryGirl::Syntax::Methods
    
    # This introduces the method `wait_for_ajax`, which can be used when the Capybara
    # matchers do not wait properly for ajax code to be finished. 
    # This is just a sleep command with a time determined by a simple benchmark.
    # 
    # see spec/support/wait_for_ajax.rb
    #
    config.include WaitForAjax
    
    # This introduces the methods `send_key(field_id, key)` and `press_enter(field_id)`.
    #
    config.include PressEnter

    # Devise test helper for controller tests
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller


    # Database Wiping Policy
    # ......................................................................................

    # For each separate test, the test database is wiped. There are several ways
    # to acomplish this. But, in high level integration tests, especially when
    # using AJAX requests, there may be complications:
    #   a) Several components are hitting the database: The test code as well as
    #        the simulated browser through Capybara. 
    #   b) There may be cases when asynchronous requests hit the database
    #        after passing on to the next test, when the database is wiped again
    #        already. Beware of these cases, which really produce strange errors.
    #
    # Some resources on this topic: 
    # * http://stackoverflow.com/questions/8178120/
    # * http://stackoverflow.com/questions/10692161/
    # * http://p373.net/2012/08/07/capybara-ajax-requirejs-and-how-to-pull-your-hair-out-in-8-easy-hours/

    config.use_transactional_fixtures = false

    config.before(:suite) do
      DatabaseCleaner.clean
    end

    config.before(:each) do

      # This distinction reduces the run time of the test suite by over a factor of 4:
      # From 40 to a couple of minutes, since the truncation method, which is slower,
      # is only used when needed by Capybara, i.e. when running integration tests,
      # possibly with asynchronous requests.
      #
      if Capybara.current_driver == :rack_test
        DatabaseCleaner.strategy = :transaction
      else
        DatabaseCleaner.strategy = :truncation
      end
      DatabaseCleaner.start

      # create the basic objects that are needed for all specs
      Group.find_or_create_everyone_group
      Group.find_or_create_corporations_parent_group
      Group.find_or_create_bvs_parent_group
      Page.create_root
      Page.create_intranet_root

    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      DatabaseCleaner.clean
    end

   
    # Spec Filtering: Focus on Current Specs
    # ......................................................................................

    # By including the `focus: true` in `describe` or `it` calls in the spec code,
    # cause the test suite to focus on these blocks, i.e. run only them. This can be
    # useful if are working on a tricky one. 
    #
    # BUT REMEMBER to reove the `focus: true` before comitting the spec code.
    # Otherwise you prevent other tests from being run regularly. 
    #    
    # config.filter_run :focus => true
    #
    # EDIT: The filter is not set here, but using guar (i.e. in the Guardfile). 
    # Thus, when using `bundle exec rake`, always all specs run,
    # which is important on the server.
    #
    config.run_all_when_everything_filtered = true


    # Further Rspec Configuration
    # ......................................................................................

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    #
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    
  end

  
  # Internationalization Settings
  # ----------------------------------------------------------------------------------------

  # Set the default locale.
  # Notice: This has to be set to the same value as in config/application.rb.
  # Because, in tests withs :js => true, the setting from config/application.rb is used.
  #
  I18n.default_locale = :de
  I18n.locale = :de
  
  
  # Request Host
  # ----------------------------------------------------------------------------------------
  
  # Override the request.host to be http://example.com rather than the default
  # http://www.example.com. Otherwise, each spec would first trigger the non-www redirect
  # in the your_platform application controller.
  #
  # http://stackoverflow.com/questions/6536503
  #
  # Edit: Does not work for all specs. 
  # For the moment, I've just deactivated the www redirect in the test env. --Fiedl
  #
  # Capybara.app_host = "http://localhost"

end


# Requirements and Configurations NOT Cached by Spork
# ==========================================================================================

# These requirements and configurations are loaded on each run of the test suite
# without being cached by Spork.
#
Spork.each_run do

  # There are some actions FactoryGirl needs to perform on every run.
  #
  FactoryGirl.reload
  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}

  # Resource on using SimpleCov together with Spork:
  # https://github.com/colszowka/simplecov/issues/42#issuecomment-4440284
  #
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
  
end
