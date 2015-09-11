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
  
  def dag_links
    links = DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true)
    links = links.where(descendant_id: @user.id) if @user
    links = links.where(ancestor_id: @group.id) if @group
    return links
  end
  
  
  def to_a
    if @direct
      find_all_direct_memberships
    else
      if @user and not @group
        find_all_memberships_by_user
      elsif @group and not @user
        find_all_memberships_by_group
      end
    end
  end
  
  delegate :count, :first, :last, to: :to_a
  
  private
  
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
      DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true, ancestor_id: descendant_group.id).collect do |direct_link|
        Membership.new(user: direct_link.descendant, group: descendant_group)
      end
    end.flatten
  end
  
end