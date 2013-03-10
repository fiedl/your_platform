module ActiveRecordJsonUrlExtension
  extend ActiveSupport::Concern

  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  def url_options
    Rails.application.config.action_mailer.default_url_options
  end

  def url
    url_for self
  end

  def serializable_hash( options = {} )
    options[ :methods ] = [ :url ] if not options[ :methods ]
    options[ :methods ] = [ options[ :methods ] ] if options[ :methods ].kind_of? Symbol
    options[ :methods ] << :url if options[ :methods ]
    raise 'options[ :methods ] should be an array' unless options[ :methods ].kind_of? Array
    super options
  end

end

ActiveRecord::Base.send( :include, ActiveRecordJsonUrlExtension )
