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
    memberships.map(&:group)
  end
  
  def direct_groups
    direct_memberships.map(&:group)
  end
  
  def indirect_groups
    indirect_memberships.map(&:group)
  end

end