class SessionsController < Devise::SessionsController

  # In order to allow guest users to sign out, skip checking if the user is already
  # signed out through devise. http://stackoverflow.com/a/26244910/2066546
  #
  skip_before_action :verify_signed_out_user

  def new
    set_current_title t :sign_in
    super
  end

  # In order to automatically remember users in devise, i.e. without having to
  # check the "remember me" checkbox, we override the setting here.
  #
  # http://stackoverflow.com/questions/14417201
  #
  # Also, this supports omniauth.
  #
  # https://github.com/plataformatec/devise/wiki/OmniAuth-with-multiple-models
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  #
  def create
    begin
      if params[:provider].present?
        auth = request.env['omniauth.auth']
        user = User.from_omniauth(auth) || raise(ActionController::BadRequest, "Omniauth user not found via email: #{auth.info.email}")
        account = user.account || raise(ActionController::BadRequest, "User has no account.")

        sign_in_and_redirect account, event: :authentication
      else
        super
      end
    rescue => error
      flash[:error] = t("errors.#{error.message}")
    end
  end

  # The original method is defined here:
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb#L25
  #
  # We override it in order to
  #   - call `destroy_current_activity`
  #   - remove cookie for guest login
  #   - redirect also for JS requests for turbolinks 5 (mobile)
  #
  def destroy
    destroy_current_activity

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?

    sign_out_guest_user

    redirect_to after_sign_out_path_for nil
  end

end
