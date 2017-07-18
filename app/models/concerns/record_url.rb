concern :RecordUrl do

  def url
    UrlHelper.new(self).url
  end

  def path
    UrlHelper.new(self).path
  end

  class UrlHelper
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::UrlFor

    def initialize(obj)
      @obj = obj
    end

    def url_options
      options = Rails.application.config.action_mailer.default_url_options || raise("Please set 'config.action_mailer.default_url_options = {host: ...}' in the application config.")
      options = options.merge({only_path: @only_path}) if not @only_path.nil?
      options[:subdomain] = options[:subdomain].call if options[:subdomain].kind_of? Proc
      options
    end

    def url
      url_for(@obj)
    end

    def path
      @only_path = true
      url_for(@obj)
    end
  end

end