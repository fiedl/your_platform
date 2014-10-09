module EventsHelper
  
  def group_to_create_the_event_for
    @group || first_group_the_current_user_can_create_events_for
  end
  
  def groups_the_current_user_can_create_events_for
    current_user.groups.find_all_by_flag(:officers_parent).collect { |op| op.parent_groups.first }
  end

  def first_group_the_current_user_can_create_events_for
    current_user.groups.find_all_by_flag(:officers_parent).first.parent_groups.first
  end
  
end