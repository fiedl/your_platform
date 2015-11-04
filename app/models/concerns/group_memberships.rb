concern :GroupMemberships do
  
  def memberships(reload = false)
    Membership.where(group: self).now
  end
  
  def direct_memberships
    memberships.direct
  end
  
  def indirect_memberships
    memberships.indirect
  end
  
  def memberships_of(user)
    memberships.where(user: user)
  end
  
  def membership_of(user)
    memberships_of(user).first
  end
  
  def memberships_for_member_list
    memberships.join_validity_ranges_of_indirect_memberships
  end
  def memberships_for_member_list_count
    cached { memberships_for_member_list.count }
  end
  
  #  This method builds a new membership having this group (self) as group associated.
  #
  def build_membership
    Membership.build(group: self)
  end
  
  def latest_memberships
    cached do
      self.memberships.with_invalid
        .select { |membership| membership.valid_from.present? }
        .sort_by { |membership| membership.valid_from }
        .last(10)
    end
  end
  
  def memberships_this_year
    cached do
      self.memberships.this_year
    end
  end
  
  def members(reload = false)
    MemberCollection.new(memberships: memberships.join_validity_ranges_of_indirect_memberships, group: self)
  end
  
  def member_ids(reload = false)
    @member_ids = nil if reload
    @member_ids ||= members.map(&:id)
  end
  
  def direct_members(reload = false)
    MemberCollection.new(memberships: memberships.direct, group: self)
  end
  
  def indirect_members
    members.indirect
  end
  
end