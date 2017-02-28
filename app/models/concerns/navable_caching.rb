concern :NavableCaching do

  included do
    cache :breadcrumbs
    cache :ancestor_nav_nodes
    cache :ancestor_navables

    cache :nav_child_page_ids
    cache :nav_child_group_ids
    cache :nav_title
  end

end