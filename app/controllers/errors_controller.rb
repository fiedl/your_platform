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
      format.json { render json: {status: request.path[1..-1], error: @exception.message} }
    end
  end

  # Unauthorized Error: Redirect to Login Page
  # -------------------------------------------------------------------------

  def unauthorized
    # If the unauthorized error is raised, make sure there are no resuduals
    # of a user by token. Otherwise, the ui could have signs of beging signed in
    # and not being signed in at the same time.
    cookies[:token] = nil

    @reason = session['exception.action'].to_s + ", " + session['exception.subject'].to_s
    if not current_devise_user
      redirect_to sign_in_path, flash: { error: I18n.t(:unauthorized_please_sign_in) }
    end
  end

end
