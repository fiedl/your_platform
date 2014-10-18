
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
  def current_ability(reload = false)
    options = {}
    @current_ability = nil if reload
    
    # Preview role mechanism
    #
    if @current_ability.nil?
      currently_displayed_object = @navable
      currently_displayed_object ||= params[:controller].singularize.camelize.constantize.unscoped.find(params[:id]) if params[:id]
      currently_displayed_object ||= Group.everyone  # this causes to determine the role for searches and indices based on the role for the everyone group.
      
      params[:preview_as] ||= load_preview_as_from_cookie
      save_preview_as_cookie(params[:preview_as])
      if params[:preview_as].present? && current_user && currently_displayed_object
        raise 'preview role not allowed!' if not params[:preview_as].in?(Role.of(current_user).for(currently_displayed_object).allowed_preview_roles)
        options[:preview_as] = params[:preview_as]
      end
    end

    @current_ability ||= ::Ability.new(current_user, params, options)
  end
  
  def reload_ability
    current_ability(true)
  end
  
  def load_preview_as_from_cookie
    cookies[:preview_as]
  end
  def save_preview_as_cookie(preview_as)
    cookies[:preview_as] = preview_as
  end
  
end
