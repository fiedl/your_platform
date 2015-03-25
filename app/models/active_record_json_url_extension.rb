module ActiveRecordJsonUrlExtension
  extend ActiveSupport::Concern

  def serializable_hash( options = {} )
    options[ :methods ] = [ :url ] if not options[ :methods ]
    options[ :methods ] = [ options[ :methods ] ] if options[ :methods ].kind_of? Symbol
    options[ :methods ] << :url if options[ :methods ]
    raise 'options[ :methods ] should be an array' unless options[ :methods ].kind_of? Array
    super options
  end

  def url
    UrlHelper.new( self ).url
  end
  
  # The following class generates a scope that prevents the url helpers
  # from being included directly into ActiveRecordJsonUrlExtension and therefore
  # into ActiveRecord::Base. 
  #
  #   class MyModel < ActiveRecord::Base
  #   end
  #
  #   my_instance = MyModel.create()
  #
  # You may call <tt>my_instance.url()</tt> to get the same result as for
  # <tt>url_for(my_instance)</tt>.
  # But you should not be able to call, for example, 
  # <tt>my_instance.my_model_path( ... )</tt>.
  #
  class UrlHelper

    include Rails.application.routes.url_helpers if Rails.version.starts_with?("3")
    include ActionDispatch::Routing::UrlFor

    def initialize( obj )
      @obj = obj
    end
    
    def url_options
      Rails.application.config.action_mailer.default_url_options
    end

    def url
      url_for @obj
    end

  end
  
end

ActiveRecord::Base.send( :include, ActiveRecordJsonUrlExtension )
