module SessionsHelper
  def current_user
    current_user_account.user if current_user_account
  end
end
