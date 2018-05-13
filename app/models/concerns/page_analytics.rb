# page analytics using the impressionist gem
# https://github.com/charlotte-ruby/impressionist
# https://trello.com/c/QzSEF9ow/1264-analytics-impressionist
#
concern :PageAnalytics do
  included do
    include Impressionist::IsImpressionable
    is_impressionable
  end

  def view_count
    self.impressionist_count
  end
end