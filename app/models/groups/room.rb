class Groups::Room < Group

  def rent
    ActionController::Base.helpers.number_to_currency(settings.rent || 100.00, unit: "")
  end

  def rent=(new_rent)
    settings.rent = new_rent.gsub(",", ".").to_f
  end

  def occupant
    members.first
  end

  def occupant_title
    direct_members_titles_string
  end

  def occupant_title=(title)
    self.direct_members_titles_string = title
  end

  def occupant_since
    memberships.first.valid_from
  end

end