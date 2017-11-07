# MiniProfiler
#
# * https://github.com/MiniProfiler/rack-mini-profiler
# * http://railscasts.com/episodes/368-miniprofiler
# * https://github.com/MiniProfiler/rack-mini-profiler/blob/master/lib/mini_profiler_rails/railtie.rb
#

# The default behaviour is to suppress mini profiler in the test environment.
#
# Use this code to activate mini profiler even in the test environment.
#
#     Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
#       return true
#     end
#
# We used this in order to test that only developers could see mini profiler.
# But having the mini profiler in the test environment caused several timeout
# issues when running on travis.
#
# Therefore, we are now back at the default behaviour.
# In addition, we have mini profiler started in hidden mode,
# i.e. pressing Alt+P is required to show it.
#
Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
  not Rails.env.test?
end

Rack::MiniProfiler.config.start_hidden = true if Rails.env.production?
Rack::MiniProfiler.config.position = 'top-right'
Rack::MiniProfiler.config.toggle_shortcut = 'Alt+P'

# We want to skip async entries for images and thumbs.
#
Rack::MiniProfiler.config.skip_paths ||= []
Rack::MiniProfiler.config.skip_paths << '/attachments'

# Activate whitelisting in production, i.e. in the controller
# `Rack::MiniProfiler.authorize_request` needs to be called in order
# to be able to use the mini profiler.
#
Rack::MiniProfiler.config.authorization_mode = :whitelist

# Profile neo4j queries.
Rails.application.config.to_prepare do
  #::Rack::MiniProfiler.profile_singleton_method(User, :non_admins) { |a| "executing all_non_admins" }
  ::Rack::MiniProfiler.profile_method(Neography::Rest, :execute_query) { |a| "executing neo4j query" }
end