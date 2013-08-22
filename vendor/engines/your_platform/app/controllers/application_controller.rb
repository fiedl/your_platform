class ApplicationController < ActionController::Base

  layout "bootstrap"

  helper_method :current_user
  
  def current_user
    current_user_account.user if current_user_account
  end

end
