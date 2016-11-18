# In a multi-server environment, the redis server can be located
# on another machine. The host name of the machine will be stored
# in the `ENV['REDIS_HOST']` environment variable.
#
# This is the lookup order for the redis host name:
#
#   1. `ENV['REDIS_HOST']`
#   2. "redis"
#   3. "localhost"

ENV['REDIS_HOST'] ||= 'redis' if (Resolv.getaddress "redis" rescue false)
ENV['REDIS_HOST'] ||= 'localhost'

# Use this class to provide a configuration for a `:redis_store`:
#
# Where you normally write
#
#     Rails.application.config.cache_store = :redis_store,
#       {host: ..., expires_in: 1.day, namespace: 'cache'}
#
# you may write
#
#     Rails.application.config.cache_store = :redis_store,
#       RedisConnectionConfiguration.new(:cache, {expires_in: 1.day}).to_hash
#
# This way, we can collect the common configuration options in the
# class below.
#
class RedisConnectionConfiguration

  # Arguments:
  # - namespace_key, e.g. "cache" or "sidekiq".
  # - options, e.g. {port: '6379', expires_in: 1.week}
  #
  def initialize(namespace_key, options = {})
    @namespace_key = namespace_key
    @options = options
    return self
  end

  def default_options
    {
      host: ENV['REDIS_HOST'],
      port: '6379',
      expires_in: 1.week,
      namespace: namespace,
      timeout: 15.0
    }
  end

  def namespace
    if Gem.loaded_specs.has_key? 'apartment'
      Proc.new { "#{::STAGE}_#{Apartment::Tenant.current}_#{@namespace_key}" }
    else
      "#{::STAGE}_#{@namespace_key}"
    end
  end

  def to_hash
    default_options.merge(@options)
  end
end

