class Graph::PageHasGroup < Graph::Link

  def link_label
    "PAGE_HAS_GROUP"
  end

  def parent_node
    Graph::Page.find(link.ancestor).find_or_create_node
  end

  def child_node
    Graph::Group.find(link.descendant).find_or_create_node
  end

end
