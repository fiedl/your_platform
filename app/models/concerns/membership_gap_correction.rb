# For some memberships, gaps need to be corrected for consistency reasons.
#
# For example, for `StatusGroup` memberships, the user is expected
# to be member of a status group of each corporation at all times.
#
# If there is a gap, then it's there by accident and needs to be corrected.
#
# Wrong:
#
#     ---no member -->|-- status 1 >|------|-- status 2 -->|----------------> time
#                                    XXXXXX
#                                    Here, the user has no status by accident.
#
# Correct:
#
#     ---no member -->|-- status 1 ------->|-- status 2 -->|----------------> time
#
concern :MembershipGapCorrection do

  class_methods do
    def apply_gap_correction(user, parent_group, options = {})
      memberships = Membership.with_past.direct.where(ancestor_type: 'Group', ancestor_id: parent_group.descendant_groups.pluck(:id), descendant_type: 'User', descendant_id: user.id)
      memberships = memberships.where(type: options[:membership_type]) if options[:membership_type]

      # Sorting the memberships by ancestor_id is a hack: The correct status order is given by the
      # status group id, which is the ancestor_id here. In cases where two memberships have the same
      # valid_from, the status group ids gives the correct order of the corporate vita.
      #
      memberships = memberships.order(:valid_from, :ancestor_id)

      memberships.to_a.to_enum.with_index.reverse_each do |membership, index| # https://stackoverflow.com/a/20248507/2066546
        following_membership = memberships[index + 1]
        membership.valid_to = following_membership.try(:valid_from)
        membership.save
      end
    end
  end

  # For status memberships, user and group can be determined
  # automatically. Thus, providing an instance method as well.
  #
  def apply_gap_correction
    Membership.apply_gap_correction(self.user, self.group.corporation, membership_type: self.type)
  end

end