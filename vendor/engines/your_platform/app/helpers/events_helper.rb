module EventsHelper
  
  def upcoming_events_list_for_group( group )
    render partial: "events/upcoming_list", locals: { events: group.upcoming_events }
  end

  def upcoming_events_list_for_user( user )
    render partial: "events/upcoming_list", locals: { events: user.upcoming_events }
  end

end
