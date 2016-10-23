# In order to set the timeout itself in the main app, add something
# like this to the `config.ru` file after `Bundler.setup`.
#
#     require "rack-timeout"
#     use Rack::Timeout
#     Rack::Timeout.timeout = 120
#
Rack::Timeout.timeout = 120

# Prevent info logging in the stderr stream.
# https://github.com/heroku/rack-timeout/issues/63#issuecomment-170416025
#
Rack::Timeout::Logger.update($stderr, ::Logger::ERROR)

