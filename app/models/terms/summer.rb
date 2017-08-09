class Terms::Summer < Term

  def start_at
    Time.zone.now.change(month: 3, day: 15, year: year)
  end
  def end_at
    Time.zone.now.change(month: 9, day: 14, year: year)
  end

  def title
    "#{I18n.t(:summer_term)} #{year.to_s}"
  end

end