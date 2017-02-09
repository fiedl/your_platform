class Terms::Year < Term

  def start_at
    Time.zone.now.change(month: 1, day: 1, year: year, hour: 0, minute: 0)
  end
  def end_at
    Time.zone.now.change(month: 12, day: 31, year: year, hour: 23, minute: 59)
  end

  def title
    year.to_s
  end

end