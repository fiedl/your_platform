concern :EventCaching do

  included do
    after_save :renew_cached_methods_of_event_ancestors
  end

  def renew_cached_methods_of_event_ancestors
    if parent
      groups = [parent] + parent.ancestor_groups
      RenewCacheJob.perform_later groups, time: Time.zone.now, method: 'event_ids_of_self_and_subgroups'
    end
  end

end