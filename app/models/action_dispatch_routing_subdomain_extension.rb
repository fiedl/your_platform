module ActionDispatch::Routing

  module RouteSetExtensions

    # This allows lambdas as subdomain parameter for `default_url_options`:
    #
    #    config.action_mailer.default_url_options = {
    #      host: 'my_platform.dev',
    #      port: 3000,
    #      protocol: 'http',
    #      subdomain: lambda { ... }
    #    }
    #
    # See also: http://stackoverflow.com/a/35209404/2066546
    #
    def url_for(options, route_name = nil, url_strategy = nil)

      if options[:subdomain].kind_of?(Proc)
        options[:subdomain] = options[:subdomain].call
      end

      if Rails.application.config.action_mailer.default_url_options[:subdomain].kind_of?(Proc)
        options[:subdomain] ||= Rails.application.config.action_mailer.default_url_options[:subdomain].call
      end

      super(options, route_name, url_strategy)

    end
  end

  class RouteSet
    prepend RouteSetExtensions
  end

end