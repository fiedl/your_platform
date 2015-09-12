# This handles the methods that can be used on memberships
# concerning validity ranges, for example, invalidating a membership.
#
# The finder methods can be found in MembershipCollectionValidityRange.
#
concern :MembershipValidityRange do
  
  concerning :Invalidation do
    # This method ends the membership, i.e. sets the end of the validity range
    # to the given time.
    # 
    # The following examples are equivalent:
    # 
    #     membership.make_invalid
    #     membership.make_invalid at: Time.zone.now
    #     membership.make_invalid Time.zone.now
    #     membership.invalidate                                    #  => membership
    #     
    def make_invalid(time = Time.zone.now)
      dag_link.try(:make_invalid, time)
      return self
    end
    
    # This is just an alias for `make_invalid`.
    #
    def invalidate(time = Time.zone.now)
      self.make_invalid(time)
    end
    
    # This method determines whether the membership can be invalidated.
    # Direct memberships can be invalidated, whereas indirect memberships cannot.
    # The validity of indirect memberships is derived from the validity of the direct ones.
    #
    def can_be_invalidated?
      self.direct?
    end
  end
  
end