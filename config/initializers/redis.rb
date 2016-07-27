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