class Pages::PublicEventsPage < Pages::PublicPage

  def semester_calendar
    group.semester_calendar
  end

  def semester_calendar!
    group.semester_calendar!
  end

  def posts
    Post.where(id: child_posts).or(Post.where(id: event_posts))
  end

  def event_posts
    Post.joins(:parent_events).merge(group.events)
  end

end