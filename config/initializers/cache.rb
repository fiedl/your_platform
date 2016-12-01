# Attention: Due to the load order, it's wise to double-check
# whether the cache store is set correctly.
# http://stackoverflow.com/a/38619281/2066546
#
# If you are not sure if it worked, implement a spec like this
# in your application:
#
#    # spec/features/smoke_spec.rb
#    feature "Smoke test" do
#      scenario "Testing the rails cache" do
#        Rails.cache.should be_kind_of ActiveSupport::Cache::RedisStore
#      end
#    end

require_relative './redis'

ENV['REDIS_HOST'] || raise('ENV["REDIS_HOST"] not set, yet.')
::STAGE || raise('::STAGE not set, yet.')


cache_redis_port = Rails.application.secrets.cache_redis_port || "6379"
Rails.application.config.cache_store = :redis_store, RedisConnectionConfiguration.new(:cache, {
  port: cache_redis_port,
  expires_in: if Rails.env.production?
      1.week
    elsif Rails.env.development?
      1.day
    elsif Rails.env.test?
      90.minutes
    end
}).to_hash

# http://stackoverflow.com/a/38619281/2066546
Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
