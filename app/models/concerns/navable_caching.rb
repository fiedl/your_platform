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

    # # If we change the title of the current navable, it will affect
    # # the navigation of the descendants.
    # #
    # # Check if the ancestor_navables of the first descendant change.
    # # If they don't, we can skip this part.
    # #
    # if self.descendants.first
    #   ancestor_navables_from_cache = self.descendants.first.read_cached :ancestor_navables
    #   new_ancestor_navables = self.descendants.first.ancestor_navables
    #
    #   if ancestor_navables_from_cache.try(:map, &:title) != new_ancestor_navables.try(:map, &:title)
    #     self.descendants.each do |descendant|
    #       if descendant.respond_to? :ancestor_nav_nodes
    #         Sidekiq::Logging.logger.info "#{self.title} # navable caching for #{descendant.title}" if Sidekiq::Logging.logger && (! Rails.env.test?)
    #
    #         descendant.ancestor_nav_nodes
    #         descendant.ancestor_navables
    #         descendant.breadcrumbs
    #       end
    #     end
    #   end
    # end
  end

end