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
    # Hitting the same url in the same session in the same minute counts as only one hit.
    self.impressionist_count(filter: "session_hash, ROUND(TIME_TO_SEC(created_at) / 60)")
  end
end