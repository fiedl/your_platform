require_relative './redis'

Sidekiq.default_worker_options = { 'backtrace' => true, retry: false }

# Define queues here instead of config/sidekiq.rb.
# This way, this defines default queues for all your_platform applications.
#
Sidekiq.options[:queues] ||= ['default', 'mailgate', 'mailers', 'cache', 'dag_links', 'retry', 'slow']


# http://stackoverflow.com/questions/14825565/sidekiq-deploy-to-multiple-environments
#
# Sidekiq does not support Proc namespacing. Thus, we have to use our own
# `Redis` object and wrap it with a redis namespace class.
#
# https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
# http://stackoverflow.com/q/40638628/2066546
#
sidekiq_redis_port = Rails.application.secrets.sidekiq_redis_port || "6379"
Sidekiq.configure_server do |config|
  require_relative "../../lib/sidekiq/fetch_newest_first"
  config.redis = ConnectionPool.new(size: 75) { RedisConnectionConfiguration.new(:sidekiq, port: sidekiq_redis_port).to_namespaced_redis }
  Sidekiq.options[:fetch] = Sidekiq::FetchNewestFirst
end
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 25) { RedisConnectionConfiguration.new(:sidekiq, port: sidekiq_redis_port).to_namespaced_redis }
end
