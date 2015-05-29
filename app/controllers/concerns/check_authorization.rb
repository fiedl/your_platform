concern :CheckAuthorization do
  
  included do
    before_action :authorize_miniprofiler
    
    # https://github.com/ryanb/cancan
    # 
    before_action :configure_permitted_devise_parameters, if: :devise_controller?
    
    check_authorization(:unless => :devise_controller?)
    
    rescue_from CanCan::AccessDenied do |exception|
      session['return_to_after_login'] = request.fullpath 
      redirect_to errors_unauthorized_url
    end
  end
  
  # MiniProfiler is a tool that shows the page load time in the top left corner of
  # the browser. But, in production, this feature should only be visible to developers.
  #
  # If the current_user can? :use the Rack::MiniProfiler, is defined in the Ability class.
  #
  def authorize_miniprofiler
    Rack::MiniProfiler.authorize_request if can? :use, Rack::MiniProfiler
  end
  
  def after_sign_in_path_for(resource)
    session['return_to_after_login'] || root_path
  end
  
  protected
  
  def configure_permitted_devise_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password) }
  end
        
end