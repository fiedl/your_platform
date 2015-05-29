concern :CurrentTimeZone do
  
  included do
    around_action :use_user_time_zone
  end
  
  def current_time_zone
    user_time_zone
  end
  
  # All times are stored in UTC in the database.
  # In order to have the application present times in the use
  # time zone used by the user, switch to the correct time zone
  # here.
  #
  # This method is called by an around_action callback above.
  #
  # See: http://railscasts.com/episodes/106-time-zones-revised
  #
  def use_user_time_zone(&block)
    Time.use_zone(user_time_zone, &block)
  end
  def user_time_zone
    # TODO: Implement a setting where the user can choose his own time zone.
    # See: http://railscasts.com/episodes/106-time-zones-revised
    "Berlin"
  end
    
end