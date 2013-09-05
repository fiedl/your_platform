require File.expand_path('../boot', __FILE__)

require 'rails/all'


# ENGINE LOAD PATCH
# This code loads the engine codes before the main app. This makes it possible
# to re-open engine classes in the main app.
# Reference: http://www.cowboycoded.com/2011/02/28/why-you-cant-reopen-rails-3-engine-classes-from-the-parent-app/
#require 'active_support/dependencies'
#module ActiveSupport::Dependencies
#  alias_method :require_or_load_without_multiple, :require_or_load
#  def require_or_load(file_name, const_path = nil)
#    if file_name.starts_with?(Rails.root.to_s + '/app')
#      relative_name = file_name.gsub(Rails.root.to_s, '')
#      @engine_paths ||= Rails::Application::Railties.engines.collect{|engine| engine.config.root.to_s }
#      @engine_paths.each do |path|
#        engine_file = File.join(path, relative_name)
#        require_or_load_without_multiple(engine_file, const_path) if File.file?(engine_file)
#      end
#    end
#    require_or_load_without_multiple(file_name, const_path)
#  end
#end
# /ENGINE LOAD PATCH



if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# config/secrets.yml
require 'yaml'
secrets_file = File.expand_path('../secrets.yml', __FILE__)
if File.exists?(secrets_file)
  ::SECRETS = YAML.load(File.read(secrets_file)) 
else
  ::SECRETS = {}
end

module Wingolfsplattform
  class Application < Rails::Application
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path = Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s] + config.i18n.load_path
    config.i18n.available_locales = [:de, :en]
    config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # 
    # This is deactivated, now, since we are using strong_parameters.
    # https://github.com/rails/strong_parameters
    #
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # http://stackoverflow.com/questions/7577236/actionviewtemplateerror-960-css-isnt-precompiled
    config.assets.precompile += [ 'wingolf_layout.css', 'bootstrap_layout.css' ]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # fix for field_with_errors in form helper, see: http://www.rabbitcreative.com/2010/09/20/rails-3-still-fucking-up-field_with_errors/
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }


    # Exceptions: Use own app as exception handler.
    # http://railscasts.com/episodes/53-handling-exceptions-revised
    config.exceptions_app = self.routes if Rails.env.production?
    
  end

end

