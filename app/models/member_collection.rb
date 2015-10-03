class MemberCollection
  
  def initialize(attrs = {})
    @group = attrs[:group]
    @memberships = attrs[:memberships] || raise('no memberships (MembershipCollection) given.')
    @memberships.kind_of?(MembershipCollection) || raise('memberships needs to be a MembershipCollection.')
  end
  
  def to_a
    @memberships.to_a.collect { |membership| membership.user }
  end
  
  def find_all_by_flag(flag)
    flagged(flag)
  end
  
  def now
    @memberships = @memberships.now
    return self
  end
  
  def with_past
    @memberships = @memberships.with_past
    return self
  end
  
  def past
    @memberships = @memberships.past
    return self
  end
  def former
    past
  end
  
  def direct
    @memberships = @memberships.direct
    return self
  end
  
  def indirect
    @memberships = @memberships.indirect
    return self
  end
  
  delegate :count, :first, :last, to: :to_a
  delegate :each, :map, :collect, :select, :include?, :+, :-, :&, to: :to_a
  
  # Add a user as another member.
  #
  def <<(user)
    @group || raise('No :group given during MemberCollection initialization.')
    @group << user
  end
    
end