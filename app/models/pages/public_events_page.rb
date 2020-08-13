class Pages::PublicEventsPage < Pages::PublicPage

  def semester_calendar
    group.semester_calendar
  end

  def semester_calendar!
    group.semester_calendar!
  end

end