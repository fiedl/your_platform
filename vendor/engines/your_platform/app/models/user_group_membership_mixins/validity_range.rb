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
module UserGroupMembershipMixins::ValidityRange
  
  extend ActiveSupport::Concern

  included do 
    attr_accessible :valid_from, :valid_to
    before_validation :set_valid_from_to_now
    
    default_scope { only_valid }
  end
  
  
  # Attributes in the database
  # ====================================================================================================
  
  def valid_from_localized_date
    self.valid_from ? I18n.localize(self.valid_from.try(:to_date)) : ""
  end
  def valid_from_localized_date=(new_date)
    self.valid_from = new_date.to_datetime
  end

  def set_valid_from_to_now
    self.valid_from ||= Time.zone.now if self.new_record?
    return self
  end
  
  
  # Invalidation
  # ====================================================================================================
  
  # This method ends the membership, i.e. sets the end of the validity range
  # to the given time.
  # 
  # The following examples are equivalent (despite the return value):
  # 
  #     membership.make_invalid
  #     membership.make_invalid at: Time.zone.now
  #     membership.make_invalid Time.zone.now
  #     membership.invalidate                                    #  => membership
  #     membership.update_attribute :valid_to, Time.zone.now     #  => true
  #     
  def make_invalid(time = Time.zone.now)
    time = time[:at] if time.kind_of?(Hash) && time[:at]
    self.update_attribute(:valid_to, time)
    return self
  end
  
  # This is just an alias for `make_invalid`.
  #
  def invalidate(time = Time.zone.now)
    self.make_invalid(time)
  end


  # Validity Check
  # ====================================================================================================
  
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


  # Temporal scopes
  # ====================================================================================================
  
  module ClassMethods
  
    # This scope returns limits the query to memberships whose validity ranges match the
    # given time.
    #
    # Example:
    #
    #     UserGroupMembership.find_all_by_user( u ).at_time( 1.hour.ago ).count
    #
    def at_time( time )
      with_invalid
        .where("valid_from IS NULL OR valid_from <= ?", time)
        .where("valid_to IS NULL OR valid_to >= ?", time)
    end
    
    # This scope limits the query to memberships that are valid at the present time.
    # This is the default bahaviour. 
    #
    def only_valid
      where("valid_from IS NULL OR valid_from <= ?", Time.zone.now)
      .where("valid_to IS NULL OR valid_to >= ?", Time.zone.now)
    end
    
    # This scope widens the query such that also memberships that are not valid at the
    # present time are returned.
    # 
    def with_invalid
      unscoped
    end
    
    # This scope limits the query to memberships that are invalid at the present time.
    # 
    def only_invalid
      with_invalid.where("valid_to < ?", Time.zone.now)
    end
    
    # This scope limits the query to memberships that are valid at the present time.
    # This is the default bahaviour. 
    #
    def now
      only_valid
    end

    # This scope limits the query to memberships that are invalid at the present time.
    # 
    def in_the_past
      only_invalid
    end

    # This scope widens the query such that also memberships that are not valid at the
    # present time are returned.
    # 
    def now_and_in_the_past
      with_invalid
    end
  
  end
  
end
