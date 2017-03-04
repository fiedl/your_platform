# A Corporation is one of the central organizational units in your_platform.
# Being a Group, the Corporation adds certain features:
#
# * The corporations of the current_user are listed as primary entry points
#   of navigation in the ui.
# * The memebrships in corporations and their subgroups are listed in the
#   users' "corporate vitae".
#
class Corporation < Group
  after_save { Corporation.corporations_parent << self }

  include CorporationGroups
  include CorporationTermReports
  include CorporationLocation

  # This returns the group that has all Corporations as children.
  # The corporations_parent itself is a Group, no Corporation.
  #
  def self.corporations_parent
    self.find_corporations_parent_group || self.create_corporations_parent_group
  end

  def self.find_corporations_parent_group
    Group.find_by_flag :corporations_parent
  end

  def self.create_corporations_parent_group
    new_group = Group.create name: 'all_corporations'
    new_group.add_flag :corporations_parent
    new_group.add_flag :group_of_groups
    Group.everyone << new_group
    return new_group
  end

  # This method returns true if this (self) is the one corporation
  # the given user has joined first, i.e. before he joined any other
  # corporation.
  #
  def is_first_corporation_this_user_has_joined?( user )
    return false if not user.groups.include? self
    return true if user.corporations.count == 1
    this_membership_valid_from = UserGroupMembership.find_by_user_and_group( user, self ).valid_from
    user.memberships.each do |membership|
      return false if membership.valid_from.to_i < this_membership_valid_from.to_i
    end
    return true
  end

  # This returns the memberships that appear in the member list
  # of the group.
  #
  # For a regular group, these are just the usual memberships.
  # For a corporation, the members of the 'former members' subgroup
  # of the corporation are excluded, even though they still have
  # memberships.
  #
  def membership_ids_for_member_list
    memberships.where.not(
      descendant_id: former_members.pluck(:id) + deceased_members.pluck(:id)
    ).pluck(:id)
  end

  # This method lists all former members of the corporation. This is not determined
  # by the user group membership validity range but by the membership in the
  # former_members sub group, since all members of subgroups are considered also
  # members of the group.
  #
  def former_members
    former_members_parent.try(:members) || User.none
  end
  def former_members_memberships
    former_members_parent.try(:memberships) || UserGroupMembership.none
  end
  def former_members_parent
    child_groups.find_by_flag(:former_members_parent)
  end

  # This method lists all deceased members of the corporation.
  #
  def deceased_members
    child_groups.find_by_flag(:deceased_parent).try(:members) || []
  end
  def deceased_members_memberships
    child_groups.find_by_flag(:deceased_parent).try(:memberships) || []
  end

  # Corporations use semester calendars to group events.
  def use_semester_calendars?
    true
  end

  include CorporationCaching if use_caching?
end
