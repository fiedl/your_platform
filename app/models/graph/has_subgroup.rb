class Graph::HasSubgroup < Graph::Link

  def self.relationship_type
    "HAS_SUBGROUP"
  end

  def parent_node
    Graph::Group.get_node(link.ancestor)
  end

  def child_node
    Graph::Group.get_node(link.descendant)
  end

  def sync_parent
    Graph::Group.sync link.ancestor
  end

  def sync_child
    Graph::Group.sync link.descendant
  end



  # def self.create_subgroup_relation(parent, child)
  #   if neo.execute_query("match (:Group {id: #{parent.id}})-[r:HAS_SUBGROUP]->(:Group {id: #{child.id}}) return r")['data'].flatten.count == 0
  #     neo.create_relationship "HAS_SUBGROUP", Graph::User.get_node(parent), Graph::User.get_node(child)
  #   end
  # end

  # def self.write_subgroup_relations
  #   DagLink.where(direct: true, ancestor_type: "Group", descendant_type: "Group").each do |link|
  #     if link.ancestor && link.descendant
  #       create_subgroup_relation link.ancestor, link.descendant
  #     end
  #   end
  # end

end
