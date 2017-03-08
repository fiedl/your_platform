concern :GroupMemberList do
  # This returns the memberships that appear in the member list
  # of the group.
  #
  # For a regular group, these are just the usual memberships.
  # For a corporation, the members of the 'former members' subgroup
  # of the corporation are excluded, even though they still have
  # memberships.
  #
  def membership_ids_for_member_list
    membership_ids
  end
  def memberships_for_member_list
    memberships_including_members.where(id: membership_ids_for_member_list)
  end
  def memberships_for_member_list_count
    memberships_for_member_list.count
  end

  def latest_memberships
    self.memberships.with_invalid.reorder('valid_from DESC').limit(10).includes(:descendant)
  end

  def memberships_this_year
    self.memberships.this_year
  end

  def memberships_including_members
    memberships.includes(:descendant).order(valid_from: :desc)
  end

end