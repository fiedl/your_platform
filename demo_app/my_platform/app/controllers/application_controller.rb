require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

class ApplicationController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

end
