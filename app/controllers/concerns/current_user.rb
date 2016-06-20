concern :CurrentUser do

  included do
    helper_method :current_user
  end

  # This method returns the currently signed in user.
  #
  def current_user
    @current_user ||= current_devise_user || current_user_by_auth_token
  end

  def current_devise_user
    current_user_account.try(:user)
  end

  def current_user_by_auth_token
    AuthToken.where(token: current_auth_token).first.try(:user) if current_auth_token
  end

  def current_auth_token
    cookies[:token] = params[:token] if params[:token]
    cookies[:token]
  end

end