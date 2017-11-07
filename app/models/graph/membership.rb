class Graph::Membership < Graph::Link

  def self.relationship_type
    "MEMBERSHIP"
  end

  def membership
    @object
  end

  def properties
    {id: membership.id, valid_from: membership.valid_from.to_s, valid_to: membership.valid_to.to_s}
  end

  def parent_node
    Graph::Group.get_node(membership.ancestor)
  end

  def child_node
    Graph::User.get_node(membership.descendant)
  end

  def sync_parent
    Graph::Group.sync membership.ancestor
  end

  def sync_child
    Graph::User.sync membership.descendant
  end

  def self.validity_range_condition(options = {})
    time = options[:time] || Time.zone.now
    membership_symbol = options[:symbol] || :m
    "(#{membership_symbol}.valid_to = '' or #{membership_symbol}.valid_to > '#{time.to_s}')"
  end

end
