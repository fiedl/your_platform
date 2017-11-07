class Graph::HasSubpage < Graph::Link

  def self.relationship_type
    "HAS_SUBPAGE"
  end

  def parent_node
    Graph::Page.get_node(link.ancestor)
  end

  def child_node
    Graph::Page.get_node(link.descendant)
  end

  def sync_parent
    Graph::Page.sync link.ancestor
  end

  def sync_child
    Graph::Page.sync link.descendant
  end

end
