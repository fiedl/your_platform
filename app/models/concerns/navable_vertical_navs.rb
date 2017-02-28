concern :NavableVerticalNavs do

  def nav_child_pages
    Page.where(id: nav_child_page_ids)
  end
  def nav_child_page_ids
    child_pages.order(:created_at).select { |page| not page.nav_node.hidden_menu }.map(&:id)
  end

  def nav_child_groups
    Group.where(id: nav_child_group_ids)
  end
  def nav_child_group_ids
    child_groups.order(:created_at).select { |group| not group.nav_node.hidden_menu }.map(&:id)
  end

  def nav_title
    nav_node.nav_title
  end

end