class SessionsController < Devise::SessionsController

  # In order to automatically remember users in devise, i.e. without having to check the
  # "remember me" checkbox, we override the setting here.
  # 
  # http://stackoverflow.com/questions/14417201/how-to-automatically-keep-user-remembered-in-devise
  #
  def create
    params[:user_account].merge!(remember_me: 1)
    super
  end

end
