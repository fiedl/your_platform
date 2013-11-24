# This class provides an interface to log events in a metrics database.
# Here, fnordmetric and redis are used.
#
# For more information, check out this resources:
#
#   * http://railscasts.com/episodes/378-fnordmetric
#   * https://github.com/paulasmuth/fnordmetric
#
# In the ApplicationController, this class is instanciated as 
# metric_logger, which is made available as controller helper method.
# 
# This, you may access this in a controller like this:
#
#   class UsersController
#     def show
#       # ...
#       metric_logger.log_event(@user, type: 'show_user')
#     end
#   end
#
class MetricLogger
  
  def initialize(options = {})
    @current_user = options[:current_user]
    @session_id = options[:session_id]
  end
  
  def current_user
    @current_user
  end
  
  def session_id
    #@session_id
    @current_user.id.to_s
  end
  
  # Log the event with the given information.
  # The FNORD_METRIC constant, which provides a direct connection to the redis
  # database, is defined in the fnordmetric initializer:
  #   config/initializers/fnordmetric.rb
  #
  # options: 
  #   type :    the type of event that is recorded here
  #
  def log_event(data, options = {})
    register_session unless options[:type].in? ["_set_name", "_set_picture"]
    data.merge!({ _type: options[:type] })
    data.merge!({ _session: session_id })
    FNORD_METRIC.event(data)
  end
  
  # This is a shortcut for one-line logs, where no current_user is required.
  # Then, one may just call:
  # 
  #   MetricLogger.log_event(...) 
  # 
  def self.log_event(data, options = {})
    self.new.log_event(data, options)
  end
  
  # These options tells fnordmetric, which user does the request. 
  #   http://fnordmetric.io/documentation/classic_event_handlers/
  #
  # We use the user's unique id as session id, since 
  def register_session
    log_event({ name: current_user.title }, type: "_set_name")
    log_event({ url: ApplicationController.helpers.user_avatar_url(current_user) }, type: "_set_picture")
  end
  
end
