class Terms::Year < Term

  def start_at
    Time.zone.now.change(month: 1, day: 11, year: year)
  end
  def end_at
    Time.zone.now.change(month: 12, day: 31, year: year)
  end

  def title
    year.to_s
  end

end