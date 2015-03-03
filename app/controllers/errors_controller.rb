class ErrorsController < ApplicationController

  skip_authorization_check
  
  # General Exception Handling: Show Message on Error Page
  # -------------------------------------------------------------------------
  #
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  #
  def show
    @exception = env["action_dispatch.exception"]
    respond_to do |format|
      format.html #{ render action: request.path[1..-1] }
      format.json { render json: {status: request.path[1..-1], error: (@exception.message || "Zeitüberschreitung (Timeout).")} }
    end
  end

  # Unauthorized Error: Redirect to Login Page
  # -------------------------------------------------------------------------

  def unauthorized
    if not current_user
      redirect_to sign_in_path, flash: { error: I18n.t(:unauthorized_please_sign_in) }
    end
  end
    
end
