# In order to set the timeout itself in the main app, add something
# like this to the `config.ru` file after `Bundler.setup`.
#
#     require "rack-timeout"
#     use Rack::Timeout
#     Rack::Timeout.timeout = 120
#
Rack::Timeout.timeout = 120
