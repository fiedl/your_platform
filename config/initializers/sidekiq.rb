require_relative './redis'

Sidekiq.default_worker_options = { 'backtrace' => true, retry: false }

# Define queues here instead of config/sidekiq.rb.
# This way, this defines default queues for all your_platform applications.
#
Sidekiq.options[:queues] = ['default', 'mailgate', 'mailers']

# https://github.com/brainopia/sidekiq-limit_fetch
#
Sidekiq.options[:limits] = {default: 25, mailgate: 1}

# http://stackoverflow.com/questions/14825565/sidekiq-deploy-to-multiple-environments
#
Sidekiq.configure_server do |config|
  config.redis = {host: ENV['REDIS_HOST'], port: '6379', namespace: "#{::STAGE}_sidekiq", timeout: 15.0 }
end

Sidekiq.configure_client do |config|
  config.redis = {host: ENV['REDIS_HOST'], port: '6379', namespace: "#{::STAGE}_sidekiq", timeout: 15.0 }
end