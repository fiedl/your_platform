concern :CurrentUser do

  included do
    helper_method :current_user
    before_action :create_guest_user_from_form_data, only: [:create]
  end

  # This method returns the currently signed in user.
  #
  def current_user
    return nil if params[:fast_lane]
    @current_user ||= current_devise_user || current_user_by_auth_token || guest_user_by_cookie
  end

  def current_devise_user
    begin
      current_user_account.try(:user)
    rescue => error
      flash[:error] = t("errors.#{error.message}")
      return nil
    end
  end

  def current_user_by_auth_token
    AuthToken.where(token: current_auth_token).first.try(:user) if current_auth_token
  end

  def current_auth_token
    cookies[:token] = params[:token] if params[:token]
    cookies[:token]
  end

  def guest_user_by_cookie
    GuestUser.find_by_name_and_email(cookies[:guest_user_name], cookies[:guest_user_email])
  end

  def create_guest_user_from_form_data
    if (name = params[:guest_user_name]).present? || (email = params[:guest_user_email] || params[:email]).present?
      unless current_user
        cookies[:guest_user_name] = name
        cookies[:guest_user_email] = email
        GuestUser.find_or_create(name, email)
        # TODO: Ask the user to sign in if user.account
      end
    end
  end

  def sign_out_guest_user
    if cookies[:guest_user_name] || cookies[:guest_user_email]
      cookies[:guest_user_name] = nil
      cookies[:guest_user_email] = nil
      set_flash_message! :notice, :signed_out
    end
  end

end