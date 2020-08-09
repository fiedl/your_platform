class Pages::PublicEventsPage < Pages::PublicPage

  def semester_calendar
    group.semester_calendars.current.first
  end

end