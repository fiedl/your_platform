require 'redis_analytics'
require_relative '../../app/models/redis_analytics/metrics'

RedisAnalytics.configure do |configuration|
  configuration.redis_connection = Redis.new(:host => 'localhost', :port => '6379')
  configuration.redis_namespace = "#{::STAGE}_redis_analytics"

  # We only want to track signed in users, not bots et cetera.
  #
  # At 2016-02, before adding this filter, we had about 1800 visits
  # per week, each visit with ca. 6 page hits and 7 minutes time
  # spent.
  #
  configuration.add_filter do |request, response|
    ## user.path == ...
    ## user = request.env['warden'].user.user if request.env['warden'].authenticate?
    #
    # Skip non-authenticated visitors:
    not request.env['warden'].authenticate?
  end

end