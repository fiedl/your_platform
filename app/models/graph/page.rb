class Graph::Page < Graph::Node

  def page
    @object
  end

  def node_label
    "Page"
  end

  def properties
    {id: page.id, title: page.title.to_s, type: page.type.to_s, published_at: page.published_at.to_s}
  end

  def sub_page_ids
    query_ids("
      match (parent:Page:#{namespace} {id: #{page.id}})-[:HAS_SUBPAGE*]->(subpages:Page)
      return distinct(subpages.id)
    ")
  end

end