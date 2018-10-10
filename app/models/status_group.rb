#
# A StatusGroup is a sub-Group of a Corporation that memberships model the
# current status of members within the corporation.
#
# At present time, the status of a user within a corporation is unique.
#
class StatusGroup < Group

  def assign_user(user, options = {})
    super(user, options).try(:becomes, Memberships::Status)
  end

  def self.find_all_by_group(group)
    group.descendant_groups.where(type: "StatusGroup")
  end

  def self.find_by_user_and_corporation(user, corporation)
    status_groups = corporation.status_groups & user.status_groups

    if status_groups.count > 1
      Membership.apply_gap_correction(user, corporation, membership_type: "Memberships::Status")
      status_groups = corporation.status_groups & user.status_groups
    end

    status_groups.last
  end

  def self.model_name
    Group.model_name
  end

end
