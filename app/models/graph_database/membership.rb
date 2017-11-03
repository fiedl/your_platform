class GraphDatabase::Membership < GraphDatabase::Link

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
    GraphDatabase::Group.get_node(membership.ancestor)
  end

  def child_node
    GraphDatabase::User.get_node(membership.descendant)
  end

  def sync_parent
    GraphDatabase::Group.sync membership.ancestor
  end

  def sync_child
    GraphDatabase::User.sync membership.descendant
  end

end
