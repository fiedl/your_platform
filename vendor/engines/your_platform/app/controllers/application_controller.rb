class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "bootstrap"

  # TODO: Change before_filter to before_action  (http://stackoverflow.com/questions/16519828)
  #
  before_filter :redirect_www_subdomain, :set_locale
  helper_method :current_user
  helper_method :current_navable, :current_navable=, :point_navigation_to
  before_filter :log_generic_metric_event
  helper_method :metric_logger
  before_filter :authorize_miniprofiler
  
  after_filter  :log_activity
  
  # This method returns the currently signed in user.
  #
  def current_user
    current_user_account.user if current_user_account
  end
  
  # This method returns the navable object the navigational elements on the 
  # currently shown page point to.
  #
  # For example, if the bread crumb navigation reads 'Start > Intranet > News', 
  # the current_navable would return the with 'News' associated navable object.
  # 
  # This also means, that the current_navable has to be set in the controller
  # through point_navigation_to.
  # 
  def current_navable
    @navable
  end
  
  # This method sets the currently shown navable object. 
  # Have a look at #current_navable.
  #
  def current_navable=( navable )
    @navable = navable
  end
  def point_navigation_to( navable )
    self.current_navable = navable
  end
  
  # Redirect the www subdomain to non-www, e.g.
  # http://www.example.com to http://example.com.
  #
  def redirect_www_subdomain
    if (request.host.split('.')[0] == 'www') and (not Rails.env.test?)
      # A flash cross-domain flash message would only work if the cookies are shared between the subdomains.
      # But we won't make this decision for the main app, since this can be a security risk on shared domains.
      # More info on sharing the cookie: http://stackoverflow.com/questions/12359522/
      #
      flash[:notice] = I18n.t(:you_may_leave_out_www)
      redirect_to "http://" + request.host.gsub('www.','')
    end
  end
  
  # The locale of the application s set as follows:
  #   1. Use the url parameter 'locale' if given.
  #   2. Use the language of the web browser if supported by the app.
  #   3. Use the default locale if no other could be determined.
  #
  def set_locale
    cookies[:locale] = secure_locale_param if params[:locale].present?
    cookies[:locale] = nil if params[:locale] and params[:locale] == ""
    cookies[:locale] = nil if cookies[:locale] == ""
    I18n.locale = cookies[:locale] || browser_language_if_supported_by_app || I18n.default_locale
  end
  
  private
  
  # This method prevents a DoS attack.
  #
  def secure_locale_param
    if params[:locale].present? and params[:locale].in? I18n.available_locales.collect { |l| l.to_s }
      params[:locale] 
    end
  end
  
  def secure_locale_from_accept_language_header
    # This comparison is to prevent a DoS attack.
    # See: http://brakemanscanner.org/docs/warning_types/denial_of_service/
    #
    I18n.available_locales.select do |locale|
      locale.to_s == locale_from_accept_language_header
    end.first
  end
  def locale_from_accept_language_header
    # see: http://guides.rubyonrails.org/i18n.html
    if request.env['HTTP_ACCEPT_LANGUAGE'] and not Rails.env.test?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end
  def browser_language_if_supported_by_app
    secure_locale_from_accept_language_header
  end
  
  # This logs the event using a metric storage.
  # Here, we use fnordmetric. The metrics can be viewed via
  #
  #   http://localhost:4242
  #
  # when the deamon is started via
  #
  #   bundle exec foreman start fnordmetric
  #
  def log_generic_metric_event
    type = "#{self.class.name.underscore}_#{action_name}"  # e.g. pages_controller_show
    metric_logger.log_event( { id: params[:id] }, type: type)
    metric_logger.log_event( { request_type: type }, type: :generic_request)
  end
  def metric_logger
    @metric_logger ||= MetricLogger.new(current_user: current_user, session_id: session[:session_id])
  end
  
  # Generic Activity Logger
  #
  def log_activity
    if not action_name.in?(["index", "show", "download", "autocomplete_title"]) and not params['controller'].in?(['sessions', 'devise/sessions'])
      begin
        type = self.class.name.gsub("Controller", "").singularize
        id = params[:id]
        object = type.constantize.find(id)
      rescue
        # there is no object associated, e.g. for the RootController
      end
      
      PublicActivity::Activity.create!(
        trackable: object,
        key: action_name,
        owner: current_user,
        parameters: params.except('authenticity_token').except('attachment')
      )
    end
  end
  
  # MiniProfiler is a tool that shows the page load time in the top left corner of
  # the browser. But, in production, this feature should only be visible to developers.
  #
  # If the current_user can? :read the :mini_profiler, is defined in the Ability class.
  #
  def authorize_miniprofiler
    Rack::MiniProfiler.authorize_request if can? :use, Rack::MiniProfiler
  end

end
