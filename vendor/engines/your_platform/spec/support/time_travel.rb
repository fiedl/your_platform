module TimeTravel
  
  # Example: time_travel 2.seconds
  #
  def time_travel(time_difference)
    Timecop.travel Time.zone.now + time_difference
  end
  
end