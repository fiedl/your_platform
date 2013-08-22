
# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join( 'app/controllers/application_controller' ).to_s

class ApplicationController
  protect_from_forgery

  before_filter      :http_authenticate

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
    redirect_to errors_unauthorized_url
  end

  protected

  def http_authenticate
    return true if ENV[ 'RAILS_ENV' ] == 'test'
    authenticate_or_request_with_http_basic do |username, password|
      username == "aki" && password == "deleted-string"
    end
  end

  def find_layout
    
    # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
    layout = "wingolf"
    layout = "bootstrap" if ENV[ 'RAILS_ENV' ] == 'test'

    if params[ :layout ]
      layout = params[ :layout ] 
    end
    return layout
  end

end
