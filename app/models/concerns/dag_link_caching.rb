concern :DagLinkCaching do

  included do
    after_save { self.delay.renew_cache }
    after_commit :delay_renew_cache_of_ancestor_and_descendant, on: :destroy
  end

  def renew_cache
    super
    delay_renew_cache_of_ancestor_and_descendant
  end

  def delay_renew_cache_of_ancestor_and_descendant
    ancestor.delay.renew_cache if ancestor
    descendant.delay.renew_cache if descendant
  end

end