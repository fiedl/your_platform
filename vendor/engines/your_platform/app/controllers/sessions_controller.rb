class SessionsController < Devise::SessionsController

  # In order to automatically remember users in devise, i.e. without having to check the
  # "remember me" checkbox, we override the setting here.
  # 
  # http://stackoverflow.com/questions/14417201/how-to-automatically-keep-user-remembered-in-devise
  #
  # Furthermore, this registers the session with the metric service in order to 
  # track the users' activities.
  #
  def create
    super
    metric_logger.register_session
  end
  
  def destroy
    current_user.update_last_seen_activity(nil) if current_user
    super
  end

end
