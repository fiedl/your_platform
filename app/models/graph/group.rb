class Graph::Group < Graph::Node

  def group
    @object
  end

  def node_label
    "Group"
  end

  def properties
    {id: group.id, name: group.name.to_s, type: group.type.to_s}
  end

  def get_member_ids
    neo.execute_query("
      match path = (group:Group {id: #{group.id}})-[:HAS_SUBGROUP*]->(g:Group)-[m:MEMBERSHIP]->(users:User)
      where #{self.class.regular_group_condition}
      and #{Graph::Membership.validity_range_condition}
      return distinct(users.id)
      union
      match path = (group:Group {id: #{group.id}})-[m:MEMBERSHIP]->(users:User)
      where #{Graph::Membership.validity_range_condition}
      return distinct(users.id)
    ")['data'].flatten
  end

  def self.get_member_ids(group)
    self.new(group).get_member_ids
  end

  def self.get_descendant_group_ids(group)
    neo.execute_query("
      match (parent:Group {id: #{group.id}})-[:HAS_SUBGROUP*]->(groups:Group)
      return groups.id
    ")['data'].flatten
  end

  def self.get_membership_ids(group)
    neo.execute_query("
      match (parent:Group {id: #{group.id}})-[memberships:MEMBERSHIP]->()
      return memberships.id
      union
      match (parent:Group {id: #{group.id}})-[:HAS_SUBGROUP*]->(g:Group)-[memberships:MEMBERSHIP]->()
      where #{regular_group_condition}
      return memberships.id
    ")['data'].flatten
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
      match (parent:Group {id: #{group.id}})-[:HAS_SUBGROUP|:HAS_EVENT*]->(events:Event)
      return distinct(events.id)
    ")
  end

end