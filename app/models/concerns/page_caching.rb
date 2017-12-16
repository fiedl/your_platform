concern :PageCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise the methods to cache are not defined, yet.
  #
  included do
    after_save { RenewCacheJob.perform_later(self, time: Time.zone.now) }

    cache :group_id
    cache :sub_page_ids
    cache :connected_descendant_page_ids
  end

  def invalidate_connected_caches
    touch_connected_pages
  end

  def touch_connected_pages
    self.touch
    connected_descendant_pages.each(&:touch)
  end

  include StructureableRoleCaching
end