concern :CurrentUser do
  
  included do
    helper_method :current_user
  end
  
  # This method returns the currently signed in user.
  #
  def current_user
    current_user_account.user if current_user_account
  end
  
end