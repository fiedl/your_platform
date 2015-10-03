concern :GroupMemberAssignment do
  
  # This assings the given user as a member to the group, i.e. this will
  # create a UserGroupMembership.
  #
  def assign_user(user, options = {})
    if user and not user.in?(self.direct_members)
      membership = Membership.create(user: user, group: self)
      time_of_joining = options[:joined_at] || options[:at] || options[:time] || Time.zone.now
      membership.update_attributes valid_from: time_of_joining
      return membership
    end
  end
  def assign(user, options = {})
    assign_user user, options
  end
  
  # This method will remove a UserGroupMembership, i.e. terminate the membership
  # of the given user in this group.
  #
  def unassign_user(user, options = {})
    if user and user.in?(self.members)
      time_of_unassignment = options[:at] || options[:time] || Time.zone.now
      Membership.where(user: user, group: self).first.invalidate(at: time_of_unassignment)
    end
  end
  def unassign(user, options = {})
    unassign_user user, options
  end
  
  # This returns a string of the titles of the direct members of this group. This is used
  # for in-place editing, for example.
  # 
  # The string would be something like this:
  # 
  #    "#{user1.title}, #{user2.title}, ..."
  #
  def direct_members_titles_string
    direct_members.collect { |user| user.title }.join( ", " )
  end
  
  # This sets the memberships of a group according to the given string of user titles.
  # 
  # For example, after calling
  # 
  #    direct_members_titles_string = "#{user1.title}, #{user2.title}",
  # 
  # the users `user1` and `user2` are the only direct members of the group.
  # The memberships are removed using the standard methods, which means that the memberships
  # are only marked as deleted. See: acts_as_paranoid_dag gem.
  #
  def direct_members_titles_string=( titles_string )
    new_members_titles = titles_string.split( "," )
    new_members = new_members_titles.collect do |title|
      u = User.find_by_title( title.strip )
      self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
      u
    end
    for member in self.direct_members
      unassign_user member unless member.in? new_members if member
    end
    for new_member in new_members
      assign_user new_member if new_member
    end
  end
    
end