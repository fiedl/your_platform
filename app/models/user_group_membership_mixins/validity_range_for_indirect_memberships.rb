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

  included do
    after_save :recalculate_indirect_validity_ranges_if_needed
  end


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
    @earliest_direct_membership ||= UserGroupMembership.with_invalid.find(earliest_direct_membership_id) if earliest_direct_membership_id
  end
  def earliest_direct_membership_id
    direct_memberships(with_invalid: true).reorder('valid_from').pluck(:id).first
  end

  def latest_direct_membership
    @latest_direct_membership ||= direct_memberships.only_valid.last
    @latest_direct_membership ||= direct_memberships(with_invalid: true).reorder('valid_to').last
  end

  def valid_from
    self.direct? ? super : (@valid_from ||= cached { earliest_direct_membership.try(:valid_from) })
  end
  def valid_from=( valid_from )
    if self.direct?
      super(valid_from)
      @need_to_recalculate_indirect_memberships = true
    else
      @valid_from = valid_from
      earliest_direct_membership.try(:valid_from=, valid_from)
    end
  end

  def valid_to
    self.direct? ? super : (@valid_to ||= latest_direct_membership.try(:valid_to))
  end
  def valid_to=( valid_to )
    if self.direct?
      super(valid_to)
      @need_to_recalculate_indirect_memberships = true
    else
      @valid_to = valid_to
      latest_direct_membership.try(:valid_to=, valid_to)
    end
  end

  # Save the current membership and auto-save also the direct memberships
  # associated with the current (maybe indirect) membership.
  #
  def save(*args)
    super(*args)
    unless self.direct?
      earliest_direct_membership.try(:save)
      latest_direct_membership.try(:save)
    end
  end

  # This method recalculates the validity range for an indirect membership.
  # This becomes necessary whenever the validity range of a direct membership is changed, so that
  # the validity range of the indirect memberships can be used in database queries,
  # for example, when using scopes.
  #
  # **Attention**: At this point, this mechanism does not cover the validity range of
  # indirect memberships where there should be a gap in the membership:
  #
  #     *----------*     *----------* (indirect membership with gap in validity range)
  #          |--------|--------|
  #     *----------*           |      (direct membership 1)
  #                      *----------* (direct membership 2)
  #
  # TODO: This has to be fiexed, probably when switching to neo4j.
  #
  def recalculate_validity_range_from_direct_memberships
    unless direct?
      old_valid_from = read_attribute :valid_from
      old_valid_to = read_attribute :valid_to
      write_attribute :valid_from, (new_valid_from = earliest_direct_membership.try(:valid_from))
      write_attribute :valid_to, (new_valid_to = latest_direct_membership.try(:valid_to))
      self.valid_from_will_change! if old_valid_from != new_valid_from
      self.valid_to_will_change! if old_valid_to != new_valid_to
    end
  end

  def recalculate_validity_range_from_direct_memberships!
    unless direct?
      self.valid_from_will_change!
      self.valid_to_will_change!
      recalculate_validity_range_from_direct_memberships
      self.valid_from_will_change!
      self.valid_to_will_change!
      save!
    else
      raise "Recalculating the validity range makes only sense for indirect memberships. This is a direct one. Membership id: #{self.id}."
    end
  end

  def recalculate_indirect_validity_ranges_if_needed
    if self.direct? and @need_to_recalculate_indirect_memberships == true
      self.indirect_memberships.each do |indirect_membership|
        indirect_membership.recalculate_validity_range_from_direct_memberships
        indirect_membership.save
      end
    end
  end
  private :recalculate_indirect_validity_ranges_if_needed



  # Invalidation
  # ====================================================================================================

  # For indirect memberships, invalidation is not possible.
  # Only direct memberships can be invalidated. The validity of the indirect memberships
  # inherts from the direct ones.
  #
  def make_invalid(time = Time.zone.now)
    raise 'An indirect membership cannot be invalidated. ' + self.user.id.to_s + ' ' + self.group.id.to_s unless direct?
    super
  end

end
