require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require 'simplecov'
  SimpleCov.start 'rails'

  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../config/environment', __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'nokogiri'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
  Dir[Rails.root.join('vendor/engines/your_platform/spec/support/**/*.rb')].each {|f| require f}

  #Remove the next line when the your_platform is extracted
  FactoryGirl.definition_file_paths = %w(spec/factories vendor/engines/your_platform/spec/factories)

  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, inspector: true)
  end
  Capybara.javascript_driver = :poltergeist

  RSpec.configure do |config|

    require 'rspec/expectations'

    config.include RSpec::Matchers
    config.include Rails.application.routes.url_helpers

    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    config.mock_with :rspec
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    # config.use_transactional_fixtures = true

    # This is to allow the creation of objects even if :js => true.
    # see * http://stackoverflow.com/questions/8178120/capybara-with-js-true-causes-test-to-fail/8698940#8698940
    #     * http://stackoverflow.com/questions/10692161/issue-with-capybara-request-specs-with-js-cant-find-the-model
    config.use_transactional_fixtures = false
    config.before :each do

      if Capybara.current_driver == :rack_test
        DatabaseCleaner.strategy = :transaction
      else
        DatabaseCleaner.strategy = :truncation
      end
      DatabaseCleaner.start

      # create the basic objects that are needed for all specs
      Group.create_everyone_group
      Group.create_corporations_parent_group
      Group.create_bvs_parent_group

      # Set the default locale.
      # Notice: This has to be set to the same value as in config/application.rb.
      # Because, in tests withs :js => true, the setting from config/application.rb is used.
      I18n.default_locale = :de
      I18n.locale = :de

    end
    config.after do
      DatabaseCleaner.clean
    end

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # FactoryGirl syntax helper
    config.include FactoryGirl::Syntax::Methods

    # set geocoder to use stubs while in test
    Geocoder.configure( lookup: :test )

    config.treat_symbols_as_metadata_keys_with_true_values = true
    #config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end


