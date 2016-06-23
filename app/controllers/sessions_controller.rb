class SessionsController < Devise::SessionsController

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

  def destroy
    destroy_current_activity
    super
  end

end
