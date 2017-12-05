class Pages::EventsPage < Page

  def events
    events = show_events_for_group.try(:events) || Event.none
    events = events.where(publish_on_global_website: true) if settings.show_only_events_published_on_global_website
    events = events.where(publish_on_local_website: true) if settings.show_only_events_published_on_local_website
    events
  end

  def show_events_for_group
    super || home_page.show_events_for_group
  end

  def self.model_name
    Page.model_name
  end

end