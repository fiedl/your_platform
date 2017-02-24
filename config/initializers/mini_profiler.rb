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
##Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
##  not Rails.env.test?
##end
##
##Rack::MiniProfiler.config.start_hidden = false
### Rack::MiniProfiler.config.skip_paths += ["/attachments/"]  # FIXME: this does not work, but we want to skip async entries for images and thumbs.
##Rack::MiniProfiler.config.toggle_shortcut = 'Ctrl+P'
##
##if Rails.env.production? || Rails.env.test?
##  Rack::MiniProfiler.config.authorization_mode = :whitelist
##end
