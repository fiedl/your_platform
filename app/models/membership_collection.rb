class MembershipCollection

  def where(constraints)
    @user = constraints[:user]
    @group = constraints[:group]
    return self
  end
  
  def direct
    @direct = true
    return self
  end
  
  def to_a
    if @direct
      find_all_direct_memberships
    else
      if @user and not @group
        find_all_memberships_by_user
      elsif @group and not @user
        find_all_memberships_by_group
      elsif @user and @group
        find_all_memberships_by_user_and_group
      end
    end
  end
  
  delegate :count, :first, :last, to: :to_a
  
  private
  
  def dag_links_for(attrs = {})
    user = attrs[:user]; group = attrs[:group]
    links = DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true)
    links = links.where(descendant_id: user.id) if user
    links = links.where(ancestor_id: group.id) if group
    return links
  end
  
  def dag_links
    dag_links_for user: @user, group: @group
  end
    
  def find_all_direct_memberships
    dag_links.collect do |direct_link|
      Membership.new(user: direct_link.descendant, group: direct_link.ancestor)
    end
  end
  
  def find_all_memberships_by_user
    find_all_direct_memberships.collect do |direct_membership|
      [ direct_membership ] + direct_membership.group.connected_ancestor_groups.collect do |ancestor_group|
        Membership.new(user: direct_membership.user, group: ancestor_group)
      end
    end.flatten
  end
  
  def find_all_memberships_by_group
    find_all_direct_memberships + @group.connected_descendant_groups.collect do |descendant_group|
      dag_links_for(group: descendant_group).collect do |direct_link|
        Membership.new(user: direct_link.descendant, group: descendant_group)
      end
    end.flatten
  end
  
  def find_all_memberships_by_user_and_group
    find_all_direct_memberships + @group.connected_descendant_groups.collect do |descendant_group|
      dag_links_for(group: descendant_group, user: @user).collect do |direct_link|
        Membership.new(user: direct_link.descendant, group: descendant_group)
      end
    end.flatten
  end
  
end