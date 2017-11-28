concern :PageEvents do

  def events
    if show_events?
      events = show_events_for_group.try(:events) || Event.all
      events = events.where(publish_on_global_website: true) if settings.show_only_events_published_on_global_website
      events = events.where(publish_on_local_website: true) if settings.show_only_events_published_on_local_website
      events
    else
      Event.none
    end
  end

  def event_ids
    events.pluck(:id)
  end

  def show_events?
    settings.show_events
  end

  def show_events_for_group
    Group.find(settings.show_events_for_group_id.to_i) if settings.show_events_for_group_id
  end

  def semester_calendar
    show_events_for_group.try(:semester_calendar)
  end

end