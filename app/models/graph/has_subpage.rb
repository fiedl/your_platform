class Graph::HasSubpage < Graph::Link

  def link_label
    "HAS_SUBPAGE"
  end

  def parent_node
    Graph::Page.find(link.ancestor).find_or_create_node
  end

  def child_node
    Graph::Page.find(link.descendant).find_or_create_node
  end

end
