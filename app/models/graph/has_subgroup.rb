class Graph::HasSubgroup < Graph::Link

  def link_label
    "HAS_SUBGROUP"
  end

  def parent_node
    Graph::Group.find(link.ancestor).find_or_create_node
  end

  def child_node
    Graph::Group.find(link.descendant).find_or_create_node
  end

end
