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
# Spring            Keeping some less frequently changing components in memory
#                   in order to increase test performance, i.e. minimize the time
#                   Guard needs to restart the tests.
#                   https://github.com/rails/spring
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
# Selenium          http://www.seleniumhq.org
# Chrome-Headless   https://robots.thoughtbot.com/headless-feature-specs-with-chrome
#
# FactoryGirls      Library to provide test data objects.
#                   https://github.com/thoughtbot/factory_girl
#

# Required Basic Libraries
# ==========================================================================================

require 'rubygems'


# Required Application Environment
# ----------------------------------------------------------------------------------------
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../demo_app/my_platform/config/environment', __FILE__)

# Does not work :(
# # Stop if the database is not migrated.
# #
# ActiveRecord::Migration.check_pending!

# The original setting whether the renew-cache mechanism should be skipped
# falling back to the delete-cache mechanism.
#
# This is default for model specs, since it makes no difference to them and the
# delete-cache mechanism is faster as caches are only filled when needed instead
# of eagerly filling every cache.
#
ENV_NO_RENEW_CACHE = ENV['NO_RENEW_CACHE']
ENV_NO_CACHING = ENV['NO_CACHING']


# Required Libraries
# ----------------------------------------------------------------------------------------

require 'rspec/rails'
require 'nokogiri'
require 'rspec/expectations'
require 'sidekiq/testing'


# Required Support Files (that help you testing)
# ----------------------------------------------------------------------------------------

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('../../spec/support/**/*.rb')].each {|f| require f}


# Factories, Stubs and Mocks
# ----------------------------------------------------------------------------------------

# Mock objects are simplified objects ("stub") that are used rather than the
# real, more complex objects, e.g. in order to increase performance.
#
# Rather than `rspec-mocks` fixtures, we use FactoryGirl instead.
#
FactoryGirl.definition_file_paths = %w(spec/factories)

# In order to not hit the geocoding API, we use stub data for geocoding.
#
Geocoder.configure( lookup: :test )


# Capybara & Poltergeist  Configuration
# ----------------------------------------------------------------------------------------

if ENV['SELENIUM']
  Capybara.register_driver :selenium_with_long_timeout do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120
    Capybara::Selenium::Driver.new(app, http_client: client)
  end
  Capybara.javascript_driver = :selenium_with_long_timeout
end
unless ENV['SELENIUM']
  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    # The `inspector: true` argument gives you the possibility to stop the execution
    # of the tests using `page.driver.debug` in your spec code. This will open an
    # inspector in the browser that allows you to see the current DOM structure and
    # other information useful for debugging tests.
    #
    Capybara::Poltergeist::Driver.new(app, {
      port: 51674 + ENV['TEST_ENV_NUMBER'].to_i,
      inspector: true,
      js_errors: (not ENV['NO_JS_ERRORS'].present?),
      timeout: 120
    })
  end
  Capybara.javascript_driver = :poltergeist
end
if ENV['USE_CHROMEDRIVER']
  require 'selenium/webdriver'
  # https://robots.thoughtbot.com/headless-feature-specs-with-chrome
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end
  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {args: %w(headless disable-gpu)}
    )
    Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      desired_capabilities: capabilities
    )
  end
  Capybara.javascript_driver = :headless_chrome
end


# Set the time that Capybara should wait for ajax requests to be finished.
# The default is 2 seconds.
#
# See: https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends
# https://docs.travis-ci.com/user/common-build-problems/#Capybara%3A-I’m-getting-errors-about-elements-not-being-found
#
# We need these huge numbers since all caching jobs are done inline
# rather than in the background.
#
Capybara.default_max_wait_time = if ENV['CI'] == 'travis'
  120 # travis is much slower and might take longer to process stuff
else
  30
end


# Background Jobs:
# Perform all background jobs immediately.
#
Sidekiq::Testing.inline!


# Rspec Configuration
# ----------------------------------------------------------------------------------------

RSpec.configure do |config|

  # rspec-rails 3 will no longer automatically infer an example group's
  # spec type from the file location. You can explicitly opt-in to this
  # feature using this snippet:
  #
  config.infer_spec_type_from_file_location!

  # Enables both, the new `expect` and the old `should` syntax.
  # https://www.relishapp.com/rspec/rspec-expectations/docs/syntax-configuration
  #
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

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
  config.include FactoryGirl::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  # TimeTravel abilities: time_travel 2.seconds
  # This can be used for caching, validity range, etc.
  #
  config.include TimeTravel

  # This introduces the method `wait_for_ajax`, which can be used when the Capybara
  # matchers do not wait properly for ajax code to be finished.
  # This is just a sleep command with a time determined by a simple benchmark.
  #
  # see spec/support/wait_for_ajax.rb
  #
  config.include WaitForAjax

  # Also, wait for the cache to invalidate.
  # This can be done with time_travel.
  #
  config.include WaitForCache

  # This introduces the methods `send_key(field_id, key)` and `press_enter(field_id)`.
  #
  config.include PressEnter

  # Auto complete fields
  #
  config.include AutoComplete

  # Workflow Kit
  #
  config.include WorkflowKit::Factory

  # Inspect the last email
  #
  config.include LastEmail

  # Debug
  # Call `debug` to enter pry.
  #
  config.include Debug

  # Devise test helper for controller tests
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  #
  # TODO: When upgrading rspec, use this instead:
  # config.include ControllerMacros

  # Include Capybara helpers
  #
  config.include CapybaraHelper, type: :feature
  config.include SessionSteps, type: :feature
  config.include WysiwygSpecHelper, type: :feature
  config.include HomePageSpecHelper, type: :feature
  config.include TabSpecHelper, type: :feature

  # Time matchers
  #
  config.include TimeMatchers


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

  config.before(:each) do

    # Do not use the renew_cache mechanism but fall back to delete_cache
    # in the model layer. This means that caches are created on the fly
    # when needed and not eagerly, which is faster.
    #
    if Capybara.current_driver == :rack_test # no integration test
      unless ENV_NO_RENEW_CACHE
        ENV['NO_RENEW_CACHE'] = "true"
      end
    else # integration test
      unless ENV_NO_RENEW_CACHE
        ENV['NO_RENEW_CACHE'] = nil
      end
    end

  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
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

    # Clear the cache.
    Rails.cache.clear unless ENV['NO_CACHING']

    # # Clear cookies
    # # https://makandracards.com/makandra/16117
    # browser = Capybara.current_session.driver.browser
    # if browser.respond_to?(:clear_cookies)
    #   # Rack::MockSession
    #   browser.clear_cookies
    # elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
    #   # Selenium::WebDriver
    #   browser.manage.delete_all_cookies
    # else
    #   raise "Don't know how to clear cookies. Weird driver?"
    # end

    # create the basic objects that are needed for all specs
    Group.find_or_create_everyone_group
    Group.find_or_create_corporations_parent_group
    Page.create_root
    Page.create_intranet_root
    Workflow.find_or_create_mark_as_deceased_workflow


    # Memory management
    # ......................................................................................

    # In order to free phantomjs memory, reset it after each spec.
    # This tries to avoid "failed to reach server".
    # https://github.com/fiedl/your_platform/pull/19#issuecomment-283803871
    #
    config.after(:each) { page.driver.reset! if defined?(page) && page.respond_to?(:driver) && page.driver.respond_to?(:reset!) }

    # Emulate Application Settings
    Setting.support_email = "support@example.com"

    # There are some actions FactoryGirl needs to perform on every run.
    #
    FactoryGirl.reload
    # Dir[Rails.root.join('../../spec/support/**/*.rb')].each {|f| require f}

  end

  config.after(:each, js: true) do
    # https://github.com/jnicklas/capybara/issues/1089
    #page.execute_script "window.stop()"
    give_it_some_time_to_finish_the_test_before_wiping_the_database
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


