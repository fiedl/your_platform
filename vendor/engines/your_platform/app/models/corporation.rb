class Corporation < Group

  # This method returns true if this (self) is the one corporation
  # the given user has joined first, i.e. before he joined any other
  # corporation.
  #
  def is_first_corporation_this_user_has_joined?( user )
    return false if not user.ancestor_groups.include? self
    return true if user.corporations.count == 1
    this_membership_created_at = UserGroupMembership.find_by_user_and_group( user, self ).created_at
    user.memberships.each do |membership|
      return false if membership.created_at < this_membership_created_at
    end
    return true
  end

  # This method returns all status groups of the corporation.
  # In this general context, each leaf group of the corporation is a status group.
  # But this is likely to be overridden by the main application.
  #
  def status_groups 
    self.descendant_groups.select do |group|
      group.descendant_groups.count == 0
    end
  end

  # This method returns all corporations in the database.
  # Usage: corporations = Corporation.all
  # 
  def self.all
    # The find_corporation_groups method is created by the GroupMixins::SpecialGroups module.
    Corporation.find_corporation_groups.collect do |group|
      # This conversion is necessary, since the find_corporation_groups method uses 
      # the child_groups method, which returns Group-type objects.
      group.becomes Corporation 
    end
  end

end
