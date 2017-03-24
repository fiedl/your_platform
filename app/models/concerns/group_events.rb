concern :GroupEvents do

  included do
    has_many :events
  end

  # group_a
  #   |----- event_0
  #   |----- group_b
  #   |        |------ event_1
  #   |        |------ user
  #   |
  #   |----- group_c
  #            |------ event_2
  #
  # event_0 is a direct event of group_a.
  # event_1 and event_2 are no direct events of group_a.
  #
  def direct_events
    events
  end

  def events_with_subgroups
    events_of_self_and_subgroups
  end

  def events_of_self_and_subgroups
    Event.where(id: event_ids_of_self_and_subgroups)
  end

  def event_ids_of_self_and_subgroups
    (self.event_ids + self.descendant_groups.map(&:event_ids_of_self_and_subgroups)).flatten
  end

  def upcoming_events
    self.events_with_subgroups.upcoming.order('start_at')
  end

end