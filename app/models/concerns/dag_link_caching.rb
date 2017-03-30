concern :DagLinkCaching do

  included do
    after_save { RenewCacheJob.perform_later(self, time: Time.zone.now) if self.changes.except(:needs_review, :updated_at).any? }
    after_commit :delay_renew_cache_of_ancestor_and_descendant, on: :destroy
  end

  def fill_cache
    super
    ancestor.try(:fill_cache)
    descendant.try(:fill_cache)
  end

  def delay_renew_cache_of_ancestor_and_descendant
    RenewCacheJob.perform_later [ancestor, descendant] - [nil], time: Time.zone.now
  end

end