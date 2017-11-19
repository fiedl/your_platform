class Graph::GroupHasPage < Graph::Link

  def link_label
    "GROUP_HAS_PAGE"
  end

  def parent_node
    Graph::Group.find(link.ancestor).find_or_create_node
  end

  def child_node
    Graph::Page.find(link.descendant).find_or_create_node
  end

end
