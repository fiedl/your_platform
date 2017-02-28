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

end