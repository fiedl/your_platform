class Terms::Winter < Term

  def start_at
    Time.zone.now.change(month: 9, day: 15, year: year)
  end
  def end_at
    Time.zone.now.change(month: 3, day: 14, year: year + 1)
  end

  def title
    "#{I18n.t(:winter_term)} #{year.to_s}/#{(year + 1).to_s.last(2)}"
  end

end