require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

class ApplicationController
  include ActiveModel::MassAssignmentSecurity

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  

  # We want the demo project in english per default.
  #
  def set_locale
    I18n.locale = cookies[:locale] || :en
  end
    
end
