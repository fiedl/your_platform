class ErrorsController < ApplicationController

  skip_authorization_check

  def unauthorized
    if not current_user
      redirect_to sign_in_path, flash: { error: I18n.t(:unauthorized_please_sign_in) }
    end
  end
end
