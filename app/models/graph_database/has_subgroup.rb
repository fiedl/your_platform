class GraphDatabase::HasSubgroup < GraphDatabase::Link

  def self.relationship_type
    "HAS_SUBGROUP"
  end

  def parent_node
    GraphDatabase::Group.get_node(link.ancestor)
  end

  def child_node
    GraphDatabase::Group.get_node(link.descendant)
  end


  # def self.create_subgroup_relation(parent, child)
  #   if neo.execute_query("match (:Group {id: #{parent.id}})-[r:HAS_SUBGROUP]->(:Group {id: #{child.id}}) return r")['data'].flatten.count == 0
  #     neo.create_relationship "HAS_SUBGROUP", GraphDatabase::User.get_node(parent), GraphDatabase::User.get_node(child)
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
