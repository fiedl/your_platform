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
      return self.reload
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
  
  concerning :ValidityCheck do
    # This method checks whether the membership is valid at the given time.
    #
    # This is not to be confused with ActiveRecord's `valid` method, which checks whether the
    # record matches the requirements to store it in the database.
    #
    # The following examples are equivalent:
    #
    #     membership.currently_valid?
    #     membership.valid_at? Time.zone.now
    # 
    def valid_at?(time)
      (self.valid_from == nil || self.valid_from <= time) && (self.valid_to == nil || self.valid_to >= time)
    end
    
    # This method checks whether the present time lies within the validity range
    # of the membership.
    #
    def currently_valid?
      valid_at?(Time.zone.now)
    end
  end
  
end