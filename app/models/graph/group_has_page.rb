class Graph::GroupHasPage < Graph::Link

  def self.relationship_type
    "GROUP_HAS_PAGE"
  end

  def parent_node
    Graph::Group.get_node(link.ancestor)
  end

  def child_node
    Graph::Page.get_node(link.descendant)
  end

  def sync_parent
    Graph::Group.sync link.ancestor
  end

  def sync_child
    Graph::Page.sync link.descendant
  end

end
