class Graph::HasEvent < Graph::Link

  # def link_label
  #   "HAS_EVENT"
  # end

  # # TODO: Reintroduce this when migrating back to a data model
  # # where events are connected to groups via dag links:
  #
  # def parent_node
  #   Graph::Group.get_node(link.ancestor)
  # end
  #
  # def child_node
  #   Graph::Event.get_node(link.descendant)
  # end
  #
  # def sync_parent
  #   Graph::Group.sync link.ancestor
  # end
  #
  # def sync_child
  #   Graph::Event.sync link.descendant
  # end

  # def self.sync(event)
  #   child_node = Graph::Event.get_node(event)
  #   parent_node = Graph::Group.get_node(event.group)
  #   neo.execute_query "MATCH (parent:Group {id: event.group.id})-[link:HAS_EVENT]->(event:Event) DELETE link"
  #   neo.create_relationship relationship_type, parent_node, child_node, {}
  # end

end
