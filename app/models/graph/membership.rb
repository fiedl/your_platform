class Graph::Membership < Graph::Link

  def link_label
    "MEMBERSHIP"
  end

  def membership
    @object
  end

  def properties
    {id: membership.id, valid_from: membership.valid_from.to_s, valid_to: membership.valid_to.to_s}
  end

  def parent_node
    Graph::Group.find(membership.ancestor).find_or_create_node
  end

  def child_node
    Graph::User.find(membership.descendant).find_or_create_node
  end

  def self.validity_range_condition(options = {})
    time = options[:time] || Time.zone.now
    membership_symbol = options[:symbol] || :m
    "(#{membership_symbol}.valid_to = '' or #{membership_symbol}.valid_to > '#{time.to_s}')"
  end

end
