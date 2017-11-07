class Graph::PageHasGroup < Graph::Link

  def self.relationship_type
    "PAGE_HAS_GROUP"
  end

  def parent_node
    Graph::Page.get_node(link.ancestor)
  end

  def child_node
    Graph::Group.get_node(link.descendant)
  end

  def sync_parent
    Graph::Page.sync link.ancestor
  end

  def sync_child
    Graph::Group.sync link.descendant
  end

end
