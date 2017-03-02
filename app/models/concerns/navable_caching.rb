concern :NavableCaching do

  included do
    cache :breadcrumbs
    cache :ancestor_nav_nodes
    cache :ancestor_navables

    cache :nav_child_page_ids
    cache :nav_child_group_ids
    cache :nav_title
  end

  def renew_cache
    super

    Rails.cache.renew do

      # If we change the title of the current navable, it will affect
      # the navigation of the descendants.
      self.descendants.each do |descendant|
        if descendant.respond_to? :ancestor_nav_nodes
          descendant.ancestor_nav_nodes
          descendant.ancestor_navables
          descendant.breadcrumbs
        end
      end

    end
  end

end