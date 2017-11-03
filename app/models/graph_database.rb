class GraphDatabase

  def self.neo
    @neo ||= Neography::Rest.new authentication: :basic, username: 'neo4j', password: 'trinity'
  end

  def self.import(group)
    write_group group
    group.descendant_groups.each { |g| write_group g }
    group.descendant_groups.each do |child|
      child.parent_groups.each { |parent| create_subgroup_relation parent, child if parent.in?([group] + group.descendant_groups) }
    end
    write_users group
    group.members.each do |user|
      user.links_as_child.each do |m|
        if m && m.direct && m.user && m.group && m.group.in?([group] + group.descendant_groups)
          write_membership m
        end
      end
    end
  end

  def self.write_user(user)
    write_object user, "User", id: user.id, name: user.name.to_s, title: user.title.to_s
  end

  def self.get_user_node(user)
    get_object_node(user, "User")
  end

  def self.write_users(group = nil)
    (group || Group.alle_wingolfiten).members.each do |user|
      write_user user
    end
  end

  def self.write_group(group)
    write_object group, "Group", name: group.name.to_s, type: group.type.to_s
  end

  def self.write_object(object, type, attributes = nil)
    node = get_object_node(object, type) || neo.create_node
    attributes ||= {name: object.name.to_s}
    attributes = attributes.merge({id: object.id, url: object.url, gid: object.gid})
    neo.reset_node_properties node, attributes
    neo.set_label node, type
    node
  end

  def self.get_group_node(group)
    get_object_node(group, "Group")
  end

  def self.get_object_node(object, type)
    neo.find_nodes_labeled(type, id: object.id).first
  end

  def self.create_subgroup_relation(parent, child)
    if neo.execute_query("match (:Group {id: #{parent.id}})-[r:HAS_SUBGROUP]->(:Group {id: #{child.id}}) return r")['data'].flatten.count == 0
      neo.create_relationship "HAS_SUBGROUP", get_group_node(parent), get_group_node(child)
    end
  end

  def self.write_groups
    Group.all.each { |g| write_group g }
  end

  def self.write_subgroup_relations
    DagLink.where(direct: true, ancestor_type: "Group", descendant_type: "Group").each do |link|
      if link.ancestor && link.descendant
        create_subgroup_relation link.ancestor, link.descendant
      end
    end
  end

  def self.get_descendant_group_ids(group)
    neo.execute_query("
      match (parent:Group {id: #{group.id}})-[:HAS_SUBGROUP*]->(groups:Group)
      return groups.id
    ")['data'].flatten
  end

  def self.get_descendant_groups(group)
    Group.find get_descendant_group_ids(group)
  end

  def self.create_group_id_index
    # In order to make finding groups by id faster.
    neo.create_schema_index "Group", ["id"]
  end

  def self.get_membership_relation(membership)
    neo.execute_query("
      match ()-[r:MEMBERSHIP]-()
      where r.id = #{membership.id}
      return r
    ")['data'].flatten.first
  end

  def self.get_or_create_membership_relation(membership)
    get_membership_relation(membership) || begin
      group_node = get_group_node(membership.group)
      user_node = get_user_node(membership.user)
      if group_node && user_node
        neo.create_relationship "MEMBERSHIP", group_node, user_node, id: membership.id
      else
        nil
      end
    end
  end

  def self.write_membership(membership)
    properties = {valid_from: membership.valid_from.to_s, valid_to: membership.valid_to.to_s}
    neo.set_relationship_properties get_or_create_membership_relation(membership)['metadata']['id'], properties
  end

  def self.write_memberships(group = nil)
    memberships = DagLink.where(ancestor_type: "Group", descendant_type: "User", direct: true, valid_to: nil)
    memberships = memberships.where(ancestor_id: [group.id] + group.descendant_groups.pluck(:id)) if group
    memberships.each do |membership|
      if membership.user.kind_of?(User) && membership.group.kind_of?(Group) && membership.user.wingolfit?
        write_membership membership
      end
    end
  end

  def self.get_member_ids(group)
    neo.execute_query("
      match path = (group:Group {id: #{group.id}})-[:HAS_SUBGROUP*]->(g:Group)-[m:MEMBERSHIP]->(users:User)
      where not g.type = 'OfficerGroup'
      and m.valid_to = ''
      return distinct(users.id)
      union
      match path = (group:Group {id: #{group.id}})-[m:MEMBERSHIP]->(users:User)
      where m.valid_to = ''
      return distinct(users.id)
    ")['data'].flatten
  end

end