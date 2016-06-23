module RedisAnalytics::Metrics
  def device_ratio_per_visit
    if user_agent.kind_of? Browser::Generic
      'desktop'
    else
      ((user_agent.device.mobile? or user_agent.device.tablet?) ? 'mobile' : 'desktop')
    end
  end
end