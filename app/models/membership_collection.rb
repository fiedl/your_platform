class MembershipCollection
  
  include MembershipCollectionValidityRange

  def where(constraints)
    @user = constraints[:user]
    @group = constraints[:group]
    return self
  end
  
  def direct
    @direct = true
    return self
  end
  
  def uniq
    @uniq = true
    return self
  end
  
  def to_a
    memberships = []
    if @direct
      memberships = find_all_direct_memberships
    else
      if @user and not @group
        memberships = find_all_memberships_by_user
      elsif @group and not @user
        memberships = find_all_memberships_by_group
      elsif @user and @group
        memberships = find_all_memberships_by_user_and_group
      end
    end
    memberships = memberships.uniq { |m| [m.group.id, m.user.id, m.valid_from, m.valid_to] } if @uniq
    return memberships
  end
  
  delegate :count, :first, :last, to: :to_a
  
  private
  
  def dag_links
    dag_links_for user: @user, group: @group
  end
    
  def find_all_direct_memberships
    dag_links.collect do |direct_link|
      Membership.new(user: direct_link.descendant, group: direct_link.ancestor, 
        valid_from: direct_link.valid_from, valid_to: direct_link.valid_to)
    end
  end
  
  def find_all_memberships_by_user
    find_all_direct_memberships.collect do |direct_membership|
      [ direct_membership ] + direct_membership.group.connected_ancestor_groups.collect do |ancestor_group|
        Membership.new(user: direct_membership.user, group: ancestor_group,
          valid_from: direct_membership.valid_from, valid_to: direct_membership.valid_to)
      end
    end.flatten
  end
  
  def find_all_memberships_by_group
    find_all_direct_memberships + @group.connected_descendant_groups.collect do |descendant_group|
      dag_links_for(group: descendant_group).collect do |direct_link|
        Membership.new(user: direct_link.descendant, group: descendant_group,
          valid_from: direct_link.valid_from, valid_to: direct_link.valid_to)
      end
    end.flatten
  end
  
  def find_all_memberships_by_user_and_group
    find_all_direct_memberships + 
    @group.connected_descendant_groups.collect do |descendant_group|
      if link = dag_links_for(group: descendant_group, user: @user).first
        Membership.new(user: @user, group: @group, valid_from: link.valid_from, valid_to: link.valid_to)
      end
    end - [nil]
  end
  
end