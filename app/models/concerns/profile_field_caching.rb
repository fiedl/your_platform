concern :ProfileFieldCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise the methods to cache are not yet defiend.
  #
  included do
    after_save :renew_cache
  end

  def renew_cache
    super
    parent.try(:renew_cache)
    profileable.renew_cache if profileable && profileable.respond_to?(:renew_cache)
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
        former_profileable.delay.renew_cache
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