concern :NavableBreadcrumbs do

  # Return breadcrumb nav nodes for a navable object.
  #
  # For example:
  #
  #     User.breadcrumbs
  #
  #     breadcrumb = User.breadcrumbs.first
  #     breadcrumb.breadcrumb_title
  #     breadcrumb.slim_breadcrum
  #
  def breadcrumbs
    nav_node.ancestor_nodes_and_self
  end

  def ancestor_nav_nodes
    nav_node.ancestor_nodes
  end

  def ancestor_navables
    ancestor_nav_nodes.map(&:navable)
  end

end