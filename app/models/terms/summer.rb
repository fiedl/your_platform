class Terms::Summer < Term

  def start_at
    Time.zone.now.change(month: 4, day: 1, year: year)
  end
  def end_at
    Time.zone.now.change(month: 9, day: 30, year: year)
  end

  def title
    "#{I18n.t(:summer_term)} #{year.to_s}"
  end

  def next
    Terms::Winter.find_or_create_by year: year
  end

  def previous
    Terms::Winter.find_or_create_by year: year - 1
  end

end