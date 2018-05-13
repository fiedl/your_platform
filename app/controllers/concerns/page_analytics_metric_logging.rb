# page analytics using the impressionist gem
# https://github.com/charlotte-ruby/impressionist
# https://trello.com/c/QzSEF9ow/1264-analytics-impressionist
#
concern :PageAnalyticsMetricLogging do
  included do
    after_action :log_page_impression, only: :show
  end

  def log_page_impression
    object = @page || @blog_post || @blog
    impressionist(object)
  end

end