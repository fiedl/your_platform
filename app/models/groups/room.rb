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

  def occupant=(new_occupant)
    assign_user new_occupant
  end

  def occupant_since
    memberships.last.try(:valid_from)
  end

  def occupant_since=(new_date)
    memberships.last.try(:update, {valid_from: new_date})
  end

  def previous_and_current_occupants
    memberships.with_past.map(&:user)
  end

  def occupancies
    memberships.with_past
  end

  def as_json(*args)
    super.merge({
      occupant: occupant,
      occupant_since: occupant_since,
      previous_and_current_occupants_count: previous_and_current_occupants.count,
      rent: rent,
      avatar_path: avatar_path,
      avatar_background_path: avatar_background_path,
      customized_avatar_background_path: customized_avatar_background_path
    })
  end

end