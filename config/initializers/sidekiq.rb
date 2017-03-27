require_relative './redis'

Sidekiq.default_worker_options = { 'backtrace' => true, retry: false }

# Define queues here instead of config/sidekiq.rb.
# This way, this defines default queues for all your_platform applications.
#
Sidekiq.options[:queues] ||= ['default', 'mailgate', 'mailers', 'cache', 'dag_links', 'retry']

# https://github.com/brainopia/sidekiq-limit_fetch
#
Sidekiq.options[:limits] = {default: 25, mailgate: 1, mailers: 5, cache: 15, dag_links: 5, retry: 1}

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
  config.redis = ConnectionPool.new(size: 25) { RedisConnectionConfiguration.new(:sidekiq, port: sidekiq_redis_port).to_namespaced_redis }
end
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5) { RedisConnectionConfiguration.new(:sidekiq, port: sidekiq_redis_port).to_namespaced_redis }
end
