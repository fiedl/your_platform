concern :MembershipValidityRangeLocalization do
  
  def valid_from_localized_date
    self.valid_from ? I18n.localize(self.valid_from.try(:to_date)) : ""
  end
  def valid_from_localized_date=(new_date)
    self.valid_from = new_date.to_datetime
  end
  
  def set_valid_from_to_now(force = false)
    self.valid_from ||= Time.zone.now if self.new_record? or force
    return self
  end
  
  def valid_to_localized_date
    self.valid_to ? I18n.localize(self.valid_to.try(:to_date)) : ""
  end
  def valid_to_localized_date=(new_date)
    if new_date == "-"
      self.valid_to = nil
    else
      self.valid_to = new_date.to_datetime
    end
  end
  
end