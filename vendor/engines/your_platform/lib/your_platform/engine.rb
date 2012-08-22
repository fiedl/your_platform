require 'carrierwave'

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
