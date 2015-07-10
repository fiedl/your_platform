Sidekiq.default_worker_options = { 'backtrace' => true, retry: false }

Sidekiq.options[:queues] = ['default', 'mailgate']

# https://github.com/brainopia/sidekiq-limit_fetch
#
Sidekiq::Queue['default'].limit = 25
Sidekiq::Queue['mailgate'].limit = 1

# http://stackoverflow.com/questions/14825565/sidekiq-deploy-to-multiple-environments
# 
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0', namespace: "#{::STAGE}_sidekiq" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0', namespace: "#{::STAGE}_sidekiq" }
end 