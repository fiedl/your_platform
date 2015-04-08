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
# Default Scope: 
#
# By default, the `only_valid` scope is applied, i.e. only memberships are 
# found that are valid at present time. To override this scope, use either
# `with_invalid` or `unscoped`.
#
# Caveats:
# * There is only one valid_from and one valid_to time per object. 
#   Therefore, you can't keep track of first archiving an object and later 
#   un-archiving it. Un-archiving an object loses the information of first archiving it.
# * Currently, the future is not handled (Article.future and article.archive at: 1.hour.from.now 
#   do not work.) But this is planned to be implemented in the future.
# 
# Some functionality has been extracted out into the temporal_scopes gem in order to 
# test the scopes easily. But, this code has been abandoned since the Rails-4 migration
# took more time.
#   => https://github.com/fiedl/temporal_scopes/blob/master/lib/temporal_scopes/has_temporal_scopes.rb
# 
module UserGroupMembershipMixins::ValidityRange
  
  extend ActiveSupport::Concern

  included do 
    attr_accessible :valid_from, :valid_to, :valid_from_localized_date, :valid_to_localized_date
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
    valid_from_will_change!
  end

  def set_valid_from_to_now(force = false)
    self.valid_from ||= Time.zone.now if self.new_record? or force
    return self
  end
  
  def valid_to_localized_date
    self.valid_to ? I18n.localize(self.valid_to.try(:to_date)) : ""
  end
  def valid_to_localized_date=(new_date)
    if new_date == "-"
      self.valid_to = nil
    else
      self.valid_to = new_date.to_datetime
    end
    valid_to_will_change!
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
  
  # This method determines whether the membership can be invalidated.
  # Direct memberships can be invalidated, whereas indirect memberships cannot.
  # The validity of indirect memberships is derived from the validity of the direct ones.
  #
  def can_be_invalidated?
    self.direct?
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
    # Rails 5 will support `.or(...)`: https://github.com/rails/rails/pull/16052
    # TODO: Refactor when migrating to Rails 5.
    #
    def only_valid
      where("valid_from IS NULL OR valid_from <= ?", Time.zone.now)
      .where("valid_to IS NULL OR valid_to >= ?", Time.zone.now)
    end
    
    # This scope widens the query such that also memberships that are not valid at the
    # present time are returned.
    # 
    # Have a look at `rewhere`.
    # https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2#diff-bf6dd6226db3aab589916f09236881c7R562
    #
    # But `rewhere` is not enough. We need more filtering:
    # https://github.com/fiedl/temporal_scopes/blob/master/lib/temporal_scopes/has_temporal_scopes.rb
    # 
    # TODO: Check if this still needs the extra filter when migrating to Rails 5.
    # 
    def with_invalid
      relation = unscope(where: [:valid_from, :valid_to])
      relation.where_values.delete_if { |query| query.to_s.include?("valid_from") || query.to_s.include?("valid_to") } 
      relation
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
    def past
      in_the_past
    end

    # This scope widens the query such that also memberships that are not valid at the
    # present time are returned.
    # 
    def now_and_in_the_past
      with_invalid
    end
    def with_past
      now_and_in_the_past
    end
    
    def this_year
      with_invalid.where("valid_from >= ?", "#{Time.zone.now.year}-01-01 00:00:00")
    end
    
    def started_after(time)
      where('NOT valid_from IS NULL').where("valid_from >= ?", time)
    end
  
  end
  
end

class Array
  def started_after(time)
    self.select { |membership| membership.valid_from && membership.valid_from >= time }
  end
end