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

class Redis
  class DynamicNamespace < BasicObject
    # Uses the given block to generate a redis namespace dynamically
    # @param options [Hash{Symbol=>Object}]
    # @option options [Redis] :redis (Redis.current)
    def initialize(namespace_proc, options = {})
      @namespace_proc = namespace_proc
      @options = options.dup
    end

    # @return [String]
    def current_namespace
      @namespace_proc.call
    end

    # @api private
    def method_missing(*a,&b)
      Namespace.new(current_namespace, @options).public_send(*a,&b)
    end
  end

  # monkey-patch Redis::Namespace to make it think that
  # DynamicNamespace is one of it
  def Namespace.===(other)
    super or other.kind_of?(DynamicNamespace)
  end
end

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
# Where you normally write
#
#     configuration.redis_connection = Redis.new({...})
#
# you may write
#
#     configuration.redis_connection =
#       RedisConnectionConfiguration.new(:redis_analytics).to_redis
#
# And if you want to apply the dynamic namespace automatically, write:
#
#     configuration.redis_connection =
#       RedisConnectionConfiguration.new(:redis_analytics).to_namespaced_redis
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

  def to_redis
    Redis.new self.to_hash
  end

  def to_namespaced_redis
    if namespace.kind_of? String
      Redis::Namespace.new(namespace, redis: to_redis)
    elsif namespace.kind_of? Proc
      Redis::DynamicNamespace.new(namespace, redis: to_redis)
    else
      raise("Don't know how to handle namespace of type #{namespace.class.name}.")
    end
  end
end

