concern :NavableCaching do

  included do
    cache :breadcrumbs
    cache :ancestor_nav_nodes
    cache :ancestor_navables

    cache :nav_child_page_ids
    cache :nav_child_group_ids
    cache :nav_title
  end

  def fill_cache
    super

    # If we change the title of the current navable, it will affect
    # the navigation of the descendants.
    self.descendants.each do |descendant|
      if descendant.respond_to? :ancestor_nav_nodes
        descendant.fill_cached_method :ancestor_nav_nodes
        descendant.fill_cached_method :ancestor_navables
        descendant.fill_cached_method :breadcrumbs
      end
    end
  end

end