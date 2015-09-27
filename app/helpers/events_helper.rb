module EventsHelper
  
  def group_to_create_the_event_for
    @group || everyone_group_if_the_user_can_create_events_there || first_group_the_current_user_can_create_events_for
  end
  
  def groups_the_current_user_can_create_events_for
    current_user.officer_groups.collect { |officer_group| officer_group.scope_group } - [nil]
  end

  def first_group_the_current_user_can_create_events_for
    current_user.officer_groups.detect { |officer_group| officer_group.scope_group }.try(:scope_group)
  end
  
  def everyone_group_if_the_user_can_create_events_there
    can?(:create_event, Group.everyone) ? Group.everyone : nil
  end
  
  def title_for_events_index
    return t :my_events if @navable == current_user
    return t :events_on_global_website if @on_global_website
    return t :events_on_local_website if @on_local_website
    return "#{t(:events_of)} '#{@group.name}'" if @group
    return t :all_events if @all
    return t :events
  end
  
end