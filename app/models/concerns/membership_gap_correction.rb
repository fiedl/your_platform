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
    def apply_gap_correction(user, parent_group)
      memberships = Membership.with_past.direct.where(ancestor_type: 'Group', ancestor_id: parent_group.descendant_groups.pluck(:id), descendant_type: 'User', descendant_id: user.id).order(:valid_from)
      memberships.to_a.to_enum.with_index.reverse_each do |membership, index| # https://stackoverflow.com/a/20248507/2066546
        following_membership = memberships[index + 1]
        membership.valid_to = following_membership.valid_from if following_membership
        membership.save
      end
    end
  end

  # For status memberships, user and group can be determined
  # automatically. Thus, providing an instance method as well.
  #
  def apply_gap_correction
    Membership.apply_gap_correction(self.user, self.group.corporation)
  end

end