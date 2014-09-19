
# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join( 'app/controllers/application_controller' ).to_s

class ApplicationController
  protect_from_forgery

  layout             :find_layout


  # Authorization: CanCan
  # ==========================================================================================
  #
  # https://github.com/ryanb/cancan
  #
  check_authorization(
                      :unless => :devise_controller? # in order to allow login
                      )

  rescue_from CanCan::AccessDenied do |exception|
    session['return_to_after_login'] = request.fullpath 
    redirect_to errors_unauthorized_url
  end
  
  protected
  
  def after_sign_in_path_for(resource)
    session['return_to_after_login'] || root_path
  end
  
  def find_layout
    
    # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
    layout = "wingolf"
    layout = "bootstrap" if Rails.env.test?
    
    layout = "minimal" if params[:layout] == "minimal"
    layout = "wingolf" if params[:layout] == "wingolf"
    layout = "bootstrap" if params[:layout] == "bootstrap"

    return layout
  end
  
  # This overrides the `current_ability` method of `cancan`
  # in order to allow additional options that are needed for a preview mechanism.
  # 
  # Warning! Make sure to handle these options very carefully to not allow
  # malicious injections.
  #
  # The original method can be found here:
  # https://github.com/ryanb/cancan/blob/master/lib/cancan/controller_additions.rb#L356
  #
  def current_ability
    options = {}
    options[:preview_as_user] = true if params[:preview_as] == 'user'

    @current_ability ||= ::Ability.new(current_user, options)
  end
  
end
