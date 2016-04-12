class GroupCollection

  def initialize(attrs = {})
    @memberships = attrs[:memberships] || raise('no memberships (MembershipCollection) given.')
    @memberships.kind_of?(MembershipCollection) || raise('memberships needs to be a MembershipCollection.')
  end

  def to_a
    groups = @memberships.to_a.collect { |membership| membership.group }
    groups = groups & Group.flagged(@flagged) if @flagged
    return groups
  end

  def flagged(flag)
    @flagged = flag
    return self
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

  def ids
    self.map(&:id)
  end

  def where
    Group.where(id: ids)
  end

  delegate :count, :first, :last, to: :to_a
  delegate :map, :collect, :select, :detect, :include?, :any?, :+, :-, :&, to: :to_a

end