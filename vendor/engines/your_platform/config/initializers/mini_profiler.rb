# MiniProfiler
#
# * https://github.com/MiniProfiler/rack-mini-profiler
# * http://railscasts.com/episodes/368-miniprofiler
# * https://github.com/MiniProfiler/rack-mini-profiler/blob/master/lib/mini_profiler_rails/railtie.rb
#

# Default: Do not activate the tool in the test environment.
# But we want to activate the tool in test environment in order to test
# that only developers can see it.
#
Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
  # !Rails.env.test?
  return true
end
if Rails.env.production? || Rails.env.test?
  Rack::MiniProfiler.config.authorization_mode = :whitelist
end

# # TODO when the app is sufficiently fast
# Rack::MiniProfiler.config.start_hidden = true   
