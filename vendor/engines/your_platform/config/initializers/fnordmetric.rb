# This establishes a connection to the redis database
# for FnordMetric.
# 
# We use the MetricLogger class as a wrapper for this:
#   your_platform:   app/model/metric_logger.rb
#  
# Have a look at these resources:
# 
#   * http://railscasts.com/episodes/378-fnordmetric
#   * https://github.com/paulasmuth/fnordmetric
#
FnordMetric.options = {
  :event_data_ttl => 1.year.seconds.to_i
  :session_data_ttl => 7.days.seconds.to_i
}

FNORD_METRIC = FnordMetric::API.new
