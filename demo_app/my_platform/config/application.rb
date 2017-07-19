require_relative 'boot'

require 'rails/all'

::STAGE = "your_platform_#{Rails.env.to_s}#{ENV['TEST_ENV_NUMBER']}"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyPlatform
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
