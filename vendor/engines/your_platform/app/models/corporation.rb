class Corporation < Group
  
  # Override the model name. This is used for the generation of paths, i.e.
  # group_path rather than corporation_path.
  # 
  def self.model_name
    Group.model_name
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
  
  # This method returns all status groups of the corporation.
  # In this general context, each leaf group of the corporation is a status group.
  # But this is likely to be overridden by the main application.
  #
  def status_groups
    StatusGroup.find_all_by_corporation(self)
  end
  
  # This method returns the status group with the given name.
  # 
  def status_group(group_name)
    status_groups.select { |g| g.name == group_name }.first
  end
  
  # This method lists all former members of the corporation. This is not determined
  # by the user group membership validity range but by the membership in the 
  # former_members sub group, since all members of subgroups are considered also 
  # members of the group.
  #
  def former_members
    child_groups.find_by_flag(:former_members_parent).members
  end
  
  # This method lists all deceased members of the corporation.
  #
  def deceased_members
    child_groups.find_by_flag(:deceased_parent).members
  end

  # This method returns all corporations in the database.
  # Usage: corporations = Corporation.all
  #
  # The Group.corporations_parent special group is defined in
  # GroupMixins::Corporations.
  # 
  def self.all
    (Group.find_corporations_parent_group.try(:child_groups) || [])
      .collect { |group| group.becomes Corporation }
      .select { |group| not group.has_flag? :officers_parent }
  end

end
