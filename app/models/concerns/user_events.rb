concern :UserEvents do

  # This method lists all upcoming events of the groups the user is member of
  # as well as all events the user has joined.
  #
  def events
    Event.find_all_by_user(self)
  end
  def upcoming_events
    events.upcoming
  end

  def event_images
    Attachment.where("content_type LIKE ?", "%image%").where(parent_type: "Event", parent_id: events.pluck(:id)).order(:created_at)
  end

  # This makes the user join an event or a grop.
  #
  def join(event_or_group)
    if event_or_group.kind_of? Group
      event_or_group.assign_user self
    elsif event_or_group.kind_of? Event
      event_or_group.attendees_group.assign_user self
    end
  end
  def leave(event_or_group)
    if event_or_group.kind_of? Group
      # TODO: Change to `unassign` when he can have multiple dag links between two nodes.
      # event_or_group.members.destroy(self)
      raise 'We need multiple dag links between two nodes!'
    elsif event_or_group.kind_of? Event
      # TODO: Change to `unassign` when he can have multiple dag links between two nodes.
      event_or_group.attendees_group.members.destroy(self)
    end
  end

end

