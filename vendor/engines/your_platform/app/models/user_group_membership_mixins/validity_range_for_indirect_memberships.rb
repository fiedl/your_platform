#
# In this project, user group memberships do not neccessarily last forever.
# They can begin at some time and end at some time. This is expressed by the
# ValidityRange of a membership.
#
# Examples:
#
#     membership.valid_from  # =>  time
#     membership.valid_to    # =>  time
#     membership.invalidate
# 
# Scopes:
#
#     UserGroupMembership.with_invalid
#     UserGroupMembership.only_valid
#     UserGroupMembership.only_invalid
#     UserGroupMembership.at_time(time)
#
# By default, the `only_valid` scope is applied, i.e. only memberships are 
# found that are valid at present time. To override this scope, use either
# `with_invalid` or `unscoped`.
#
module UserGroupMembershipMixins::ValidityRangeForIndirectMemberships
  
  extend ActiveSupport::Concern
  

  # Validity Range Attributes
  # ====================================================================================================
  
  # The validity range attributes are inherited for indirect memberships.
  #
  #       *-----------------(c)--------------------*
  #                          |
  #                |--------------------|
  #                |                    |
  #       *-------(a)--------*          | 
  #                          *---------(b)---------*
  #
  #       _________________________________________________________
  #       t1                 t2                    t3      time -->
  #
  # If membership A is valid from t1 to t2 and membership B is valid from t2 to t3
  # and membership C is the indirect membership that results from the memberships
  # A and B, then C is valid from t1 to t3.
  #
  # This means that the valid_from attribute is derived from the valid_from attribute
  # of the earliest direct membership. The valid_to attribute is derived from the
  # latest direct membership.
  #
  def earliest_direct_membership
    @earliest_direct_membership ||= direct_memberships(with_invalid: true).reorder(:valid_from).first
  end
  
  def latest_direct_membership
    @latest_direct_membership ||= direct_memberships.only_valid.last
    @latest_direct_membership ||= direct_memberships(with_invalid: true).reorder(:valid_to).last
  end
  
  def valid_from
    self.direct? ? super : earliest_direct_membership.try(:valid_from)
  end
  def valid_from=( valid_from )
    self.direct? ? super(valid_from) : earliest_direct_membership.try(:valid_from=, valid_from)
  end
  
  def valid_to
    self.direct? ? super : latest_direct_membership.try(:valid_to)
  end
  def valid_to=( valid_to )
    self.direct? ? super(valid_to) : latest_direct_membership.try(:valid_to=, valid_to)
  end

  # Save the current membership and auto-save also the direct memberships
  # associated with the current (maybe indirect) membership.
  #
  def save(*args)
    unless self.direct?
      earliest_direct_membership.try(:save)
      latest_direct_membership.try(:save)
    end
    super(*args)
  end
  
  
  # Invalidation
  # ====================================================================================================
  
  # For indirect memberships, invalidation is not possible.
  # Only direct memberships can be invalidated. The validity of the indirect memberships
  # inherts from the direct ones.
  #
  def make_invalid(time = Time.zone.now)
    raise 'An indirect membership cannot be invalidated.' unless direct?
    super
  end
  
  
  # # Validity Check
  # # ====================================================================================================
  # 
  # # This method checks whether the membership is valid at the given time.
  # # For indirect memberships, the validity inherits from the direct membership.
  # #
  # # 
  # def valid_at?(time)
  #   (valid_from == nil || valid_from <= time) && (valid_to == nil || valid_to >= time)
  # end
  # 
  # # This method checks whether the present time lies within the validity range
  # # of the membership.
  # #
  # def currently_valid?
  #   valid_at?(Time.zone.now)
  # end
  # 
  # 
  # # Temporal scopes
  # # ====================================================================================================
  # 
  # module ClassMethods
  # 
  #   # This scope returns limits the query to memberships whose validity ranges match the
  #   # given time.
  #   #
  #   # Example:
  #   #
  #   #     UserGroupMembership.find_all_by_user( u ).at_time( 1.hour.ago ).count
  #   #
  #   def at_time( time )
  #     with_invalid
  #       .where("valid_from IS NULL OR valid_from <= ?", time)
  #       .where("valid_to IS NULL OR valid_to >= ?", time)
  #   end
  #   
  #   # This scope limits the query to memberships that are valid at the present time.
  #   # This is the default bahaviour. 
  #   #
  #   def only_valid
  #     at_time Time.zone.now
  #   end
  #   
  #   # This scope widens the query such that also memberships that are not valid at the
  #   # present time are returned.
  #   # 
  #   def with_invalid
  #     unscoped
  #   end
  #   
  #   # This scope limits the query to memberships that are invalid at the present time.
  #   # 
  #   def only_invalid
  #     with_invalid.where("valid_to < ?", Time.zone.now)
  #   end
  # 
  # end
  
end
