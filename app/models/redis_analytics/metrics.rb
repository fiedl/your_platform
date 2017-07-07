module RedisAnalytics::Metrics
  def device_ratio_per_visit
    if user_agent.known?
      ((user_agent.device.mobile? or user_agent.device.tablet?) ? 'mobile' : 'desktop')
    else
      'desktop'
    end
  end
end