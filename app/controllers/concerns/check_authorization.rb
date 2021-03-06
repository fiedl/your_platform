concern :CheckAuthorization do

  included do
    before_action :authorize_miniprofiler

    # https://github.com/ryanb/cancan
    #
    before_action :configure_permitted_devise_parameters, if: :devise_controller?

    check_authorization(:unless => :devise_controller?)
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
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource)
    sign_in_path
  end

  protected

  def configure_permitted_devise_parameters
    # https://github.com/plataformatec/devise/blob/master/
    # lib/devise/parameter_sanitizer.rb
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password])
  end

end