concern :CorporationAccommodations do

  def accommodations_institution
    child_groups.where(type: "Groups::Wohnheimsverein").first
  end

  def occupants_parent_group
    sub_group("Hausbewohner")
  end

  def rooms
    occupants_parent_group.child_groups.where(type: "Groups::Room")
  end

  def create_room(params)
    new_room = Groups::Room.create params.merge({type: "Groups::Room"})
    occupants_parent_group.child_groups << new_room
    return new_room
  end

end