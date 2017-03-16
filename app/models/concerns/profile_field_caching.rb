concern :ProfileFieldCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise the methods to cache are not yet defiend.
  #
  included do
    after_save { RenewCacheJob.perform_later(self, time: Time.zone.now) }
  end

  def fill_cache
    super
    parent.fill_cache if parent && parent.children.first.id == self.id
    if !parent && profileable && profileable.respond_to?(:renew_cache)
      self.class.cached_profileable_methods_depending_on_profile_fields.each do |method|
        profileable.send method
      end
    end
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
        RenewCacheJob.perform_later(former_profileable, time: Time.zone.now,
            methods: self.class.cached_profileable_methods_depending_on_profile_fields)
      end
    end
  end

  class_methods do

    def cached_profileable_methods_depending_on_profile_fields
      %w(date_of_birth date_of_death age birthday_this_year email name_with_surrounding address_label)
    end

  end

end