concern :UserMemberships do
  
  def memberships
    Membership.where(user: self).now
  end
  
  def direct_memberships
    memberships.direct
  end
  
  def indirect_memberships
    memberships.indirect
  end
  
  def memberships_in(group)
    memberships.where(group: group)
  end
  
  def membership_in(group)
    memberships_in(group).first
  end
  
  def groups
    GroupCollection.new(memberships: memberships.join_validity_ranges_of_indirect_memberships)
  end
  
  def direct_groups
    GroupCollection.new(memberships: direct_memberships)
  end
  
  def indirect_groups
    GroupCollection.new(memberships: indirect_memberships.join_validity_ranges_of_indirect_memberships)
  end

end