concern :ProfileFieldCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise the methods to cache are not yet defiend.
  #
  included do
    after_save { RenewCacheJob.perform_later(self, Time.zone.now) }
  end

  def fill_cache
    super
    parent.try(:fill_cache)
    profileable.fill_cache if profileable && profileable.respond_to?(:fill_cache)
  end

  def destroy
    unassociate_profileable_and_renew_profileable_cache
    super
  end

  def unassociate_profileable_and_renew_profileable_cache
    if not parent
      former_profileable = profileable
      self.profileable = nil
      self.save
      if former_profileable && former_profileable.respond_to?(:renew_cache)
        RenewCacheJob.perform_later(former_profileable, Time.zone.now)
      end
    end
  end

  def fill_cache
    # Nothing to do here in the base class.
  end

  def delete_cache
    super
    parent.try(:delete_cache)
    profileable.delete_cache if profileable && profileable.respond_to?(:delete_cache)
  end

end