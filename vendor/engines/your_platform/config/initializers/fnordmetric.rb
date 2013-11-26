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
unless Rails.env.test?
  FNORD_METRIC = FnordMetric::API.new
end
