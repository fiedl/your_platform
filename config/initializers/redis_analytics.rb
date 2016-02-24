require 'redis_analytics'

RedisAnalytics.configure do |configuration|
  configuration.redis_connection = Redis.new(:host => 'localhost', :port => '6379')
  configuration.redis_namespace = "#{::STAGE}_redis_analytics"
end