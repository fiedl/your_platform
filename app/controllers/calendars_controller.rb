class CalendarsController < ApplicationController

  expose :timezone, -> { current_user.timezone || "Berlin" }
  expose :calendars, -> {
    current_user.groups.joins(:events).collect { |group|
      {
        name: group.name,
        events: group.events,
        editable: can?(:create_event, group),
        checked: true,
        category: "Meine Kalender",
        ical_feed_url: group_events_url(group_id: group.id, format: 'ics', protocol: 'webcal')
      }
    } + [
      {
        name: "Große Veranstaltungen aus dem Bund",
        events: Event.where(publish_on_global_website: true),
        editable: false,
        checked: true,
        category: "Wingolfsbund",
        ical_feed_url: public_events_url(format: 'ics', protocol: 'webcal')
      },
      {
        name: "Stiftungsfeste",
        events: Event.commers,
        editable: false,
        checked: false,
        category: "Wingolfsbund"
      },
      {
        name: "Wartburgfeste",
        events: Event.wartburgfest,
        editable: false,
        checked: false,
        category: "Wingolfsbund"
      },
      {
        name: "Wingolfsseminare",
        events: Event.wingolfsseminar,
        editable: false,
        checked: false,
        category: "Wingolfsbund"
      }
    ] +
    Corporation.active.select { |corporation|
      not corporation.in? current_user.corporations
    }.collect { |corporation|
      {
        name: corporation.title,
        events: [],
        editable: can?(:create_event, corporation),
        checked: false,
        category: "Andere Verbindungen",
        ical_feed_url: group_events_url(group_id: corporation.id, format: 'ics', protocol: 'webcal')
      }
    }
  }

  def index
    authorize! :index, :calendars

    set_current_title "Kalender"
    set_current_tab :events
  end

end