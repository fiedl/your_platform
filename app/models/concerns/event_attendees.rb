concern :EventAttendees do

  def find_attendees_group
    find_special_group :attendees
  end
  def create_attendees_group
    create_special_group :attendees
  end
  def attendees_group
    find_attendees_group || create_attendees_group
  end
  def attendees
    attendees_group.members
  end

  def destroy
    find_attendees_group.try(:destroy)
    super
  end

end