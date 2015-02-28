module ActiveRecordMetricEventsExtension
#   extend ActiveSupport::Concern
# 
#   # This triggers a event for the metric logger service.
#   #
#   # Example:
#   # 
#   # class PagesController
#   #   def show
#   #     # ...
#   #     @page.log_metric_event(:show)
#   #   end
#   # end
#   #
#   def log_metric_event(type)
#     type = "#{type}_#{self.class.name.underscore}"  # e.g. show_page
#     MetricLogger.log_event(self.attributes, type: type)
#   end
#   
end

# ActiveRecord::Base.send( :include, ActiveRecordMetricEventsExtension )
