class SessionsController < Devise::SessionsController

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
    if params[:provider].present?
      auth = request.env['omniauth.auth']
      user = User.from_omniauth(auth) || raise("Omniauth user not found via email: #{auth.info.email}")
      account = user.account || raise("User has no account.")

      sign_in_and_redirect account, event: :authentication
    else
      super
    end
  end

  # The original method is defined here:
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb#L25
  #
  # We override it in order to
  #   - call `destroy_current_activity`
  #   - redirect also for JS requests for turbolinks 5 (mobile)
  #
  def destroy
    destroy_current_activity

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?

    redirect_to after_sign_out_path_for nil
  end

end
