class Graph::Group < Graph::Node

  def group
    @object
  end

  def node_label
    "Group"
  end

  def properties
    {id: group.id, name: group.name.to_s, token: group.token.to_s, type: group.type.to_s}
  end

  def descendant_member_ids
    query_ids("
      match path = (group:Group:#{namespace} {id: #{group.id}})-[:HAS_SUBGROUP*0..999]->(g:Group)-[m:MEMBERSHIP]->(users:User)
      where #{self.class.regular_group_condition}
      and #{Graph::Membership.validity_range_condition}
      return distinct(users.id)
    ")
  end

  def descendant_group_ids
    query_ids("
      match (parent:Group:#{namespace} {id: #{group.id}})-[:HAS_SUBGROUP*]->(groups:Group)
      return groups.id
    ")
  end

  def descendant_membership_ids
    query_ids("
    match (parent:Group:#{namespace} {id: #{group.id}})-[:HAS_SUBGROUP*0..999]->(g:Group)-[memberships:MEMBERSHIP]->()
    where #{self.class.regular_group_condition}
    return memberships.id
    ")
  end

  def self.create_group_id_index
    # In order to make finding groups by id faster.
    neo.create_schema_index "Group", ["id"]
  end

  def self.regular_group_condition(options = {})
    group_symbol = options[:symbol] || :g
    "(not #{group_symbol}.type = 'OfficerGroup')"
  end

  def descendant_event_ids
    query_ids("
      match (parent:Group:#{namespace} {id: #{group.id}})-[:HAS_SUBGROUP|:HAS_EVENT*]->(events:Event)
      return distinct(events.id)
    ")
  end

end