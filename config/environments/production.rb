Wingolfsplattform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # This uses a redirect and does not set the default protocol for hyperlinks.
  # For wingolfsplattform, the redirect is already done via nginx.
  #
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Load Secret Settings
  # -> moved to config/application.rb

  # SMTP Settings
  config.action_mailer.delivery_method = :smtp

  smtp_password = ::SECRETS["wingolfsplattform@wingolf.org_smtp_password"]
  unless smtp_password
    raise "
      No smtp password set in config/secrets.yml.
      Please have a look at config/secrets.yml.example and set the key
        wingolfsplattform@wingolf.org_smtp_password
      in config/secrets.yml.
    "
  end

  config.action_mailer.smtp_settings = {
    address: 'smtp.1und1.de',
    user_name: 'wingolfsplattform@wingolf.org',
    password: smtp_password,
    domain: 'wingolfsplattform.org',
    enable_starttls_auto: true,
    # only if certificate malfunctions:
    # openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  
  # Rails-4 syntax:  (see http://stackoverflow.com/a/12609856/2066546)
  #   config.action_mailer.default_options = {    
  #     from: 'Wingolfsplattform <wingolfsplattform@wingolf.org>'
  #   }
  # Rails-3 syntax:
  ActionMailer::Base.default from: 'Wingolfsplattform <wingolfsplattform@wingolf.org>'
  
  config.action_mailer.default_url_options = { host: 'wingolfsplattform.org', protocol: 'https' }

end
