Apipie.configure do |config|
  config.app_name                = "#{Rails.application.class.parent_name}: API"
  config.app_info                = "YourPlatform: Administrative and social network platform for closed user groups. See: https://github.com/fiedl/your_platform."
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  #config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.api_controllers_matcher = "#{YourPlatform::Engine.root}/app/controllers/api/**/*.rb"
  config.reload_controllers      = Rails.env.development?
end

