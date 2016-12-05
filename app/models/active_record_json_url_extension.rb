module ActiveRecordJsonUrlExtension
  extend ActiveSupport::Concern

  # def serializable_hash(options = {})
  #   options[:methods] = [:url] if not options[:methods]
  #   options[:methods] = [options[:methods]] if options[:methods].kind_of? Symbol
  #   options[:methods] << :url if options[:methods]
  #   raise 'options[:methods] should be an array' unless options[:methods].kind_of? Array
  #   super options
  # end

  def url
    UrlHelper.new(self).url
  end

  def path
    UrlHelper.new(self).path
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
  # You may call `my_instance.url()` to get the same result as for
  # `url_for(my_instance)`.
  # But you should not be able to call, for example,
  # `my_instance.my_model_path( ... )`.
  #
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

ActiveRecord::Base.send(:include, ActiveRecordJsonUrlExtension)
