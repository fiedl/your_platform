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

  # def self.get_or_create_membership_relation(membership)
  #   get_membership_relation(membership) || begin
  #     group_node = GraphDatabase::User.get_node(membership.group)
  #     user_node = GraphDatabase::User.get_node(membership.user)
  #     if group_node && user_node
  #       neo.create_relationship "MEMBERSHIP", group_node, user_node, id: membership.id
  #     else
  #       nil
  #     end
  #   end
  # end
  #
  # def self.write_membership(membership)
  #   properties = {valid_from: membership.valid_from.to_s, valid_to: membership.valid_to.to_s}
  #   neo.set_relationship_properties get_or_create_membership_relation(membership)['metadata']['id'], properties
  # end
  #
  # def self.write_memberships(group = nil)
  #   memberships = DagLink.where(ancestor_type: "Group", descendant_type: "User", direct: true, valid_to: nil)
  #   memberships = memberships.where(ancestor_id: [group.id] + group.descendant_groups.pluck(:id)) if group
  #   memberships.each do |membership|
  #     if membership.user.kind_of?(User) && membership.group.kind_of?(Group) && membership.user.wingolfit?
  #       write_membership membership
  #     end
  #   end
  # end

end
