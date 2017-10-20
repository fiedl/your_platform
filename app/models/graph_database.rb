class GraphDatabase

  def self.neo
    @neo ||= Neography::Rest.new authentication: :basic, username: 'neo4j', password: 'trinity'
  end

  def self.write_user(user)
    write_object user, "User"
  end

  def self.get_user_node(user)
    get_object_node(user, "User")
  end

  def self.write_group(group)
    write_object group, "Group"
  end

  def self.write_object(object, type)
    node = get_object_node(object, type) || neo.create_node
    neo.reset_node_properties node, id: object.id, name: object.name.to_s, url: object.url, gid: object.gid
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
    neo.create_relationship "IS_SUBGROUP_OF", get_group_node(parent), get_group_node(child)
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
      match (parent:Group), (groups:Group)
      where parent.id = #{group.id}
      and (parent)-[:IS_SUBGROUP_OF*1..100]->(groups)
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

end