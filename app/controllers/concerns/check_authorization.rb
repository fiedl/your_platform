concern :CheckAuthorization do

  included do
    before_action :authorize_miniprofiler

    # https://github.com/ryanb/cancan
    #
    before_action :configure_permitted_devise_parameters, if: :devise_controller?

    check_authorization(:unless => :devise_controller?)


    rescue_from CanCan::AccessDenied do |exception|
      Rails.logger.info "Access denied for user #{current_user.try(:id)} on #{exception.action} for #{session['exception.subject']}."
      if request.format.html? || controller_name == "attachment_downloads"
        session['exception.action'] = exception.action
        if exception.subject.kind_of?(String) or exception.subject.kind_of?(Symbol)
          session['exception.subject'] = exception.subject
        else
          session['exception.subject'] = "#{exception.subject.class.name} #{exception.subject.id if exception.subject.respond_to?(:id)}"
          # exception.subject.to_s.first(50)
        end
        session['return_to_after_login'] = request.fullpath
        store_location_for :user_account, request.fullpath
        redirect_to errors_unauthorized_url
      else
        raise CanCan::AccessDenied, exception
      end
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