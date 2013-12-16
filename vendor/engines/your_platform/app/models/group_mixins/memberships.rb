# 
# This module contains the methods of the Group model regarding the associated 
# user group memberships and users, i.e. members.
#
module GroupMixins::Memberships
  
  extend ActiveSupport::Concern
  
  # TODO: Refactor conditions to rails 4 standard when migrating to rails 4.
  # See, for example, https://github.com/fiedl/neo4j_ancestry/blob/master/lib/models/neo4j_ancestry/active_record_additions.rb#L117.
  
  # TODO: Clean up group_spec.
    
  included do

    # User Group Memberships
    # ==========================================================================================
    
    # This associates all UserGroupMembership objects of the group, including indirect 
    # memberships.
    #
    has_many( :memberships, 
              class_name: 'UserGroupMembership', #inverse_of: :groups, # TODO: make :groups an association in UserGroupMembership
              foreign_key: :ancestor_id, conditions: { ancestor_type: 'Group' } )
    
    # This associates all memberships of the group that are direct, i.e. direct 
    # parent_group-child_user memberships.
    #
    has_many( :direct_memberships,
              class_name: 'UserGroupMembership', 
              foreign_key: :ancestor_id, conditions: { ancestor_type: 'Group', direct: true } )
              
   # This associates all memberships of the group that are indirect, i.e. 
   # ancestor_group-descendant_user memberships, where groups are between the
   # ancestor_group and the descendant_user.
   #
   has_many( :indirect_memberships,
             class_name: 'UserGroupMembership', 
             foreign_key: :ancestor_id, conditions: { ancestor_type: 'Group', direct: false } )
    
  end

  #  This method builds a new membership having this group (self) as group associated.
  #
  def build_membership
    direct_memberships.build(descendant_type: 'User')
  end
  
  # This returns the UserGroupMembership object that represents the membership of the 
  # given user in this group.
  # 
  def membership_of( user )
    memberships.where(descendant_id: user.id).first
  end
  

  # User Assignment
  # ==========================================================================================
  
  # This assings the given user as a member to the group, i.e. this will
  # create a UserGroupMembership.
  #
  def assign_user( user, options = {} )
    if user and not user.in?(self.direct_members)
      membership = UserGroupMembership.create(user: user, group: self)
  
      time_of_joining = options[:joined_at] || options[:at] || options[:time] || Time.zone.now
      membership.update_attribute(:valid_from, time_of_joining)
  
      return membership
    end
  end
  
  # This method will remove a UserGroupMembership, i.e. terminate the membership
  # of the given user in this group.
  #
  def unassign_user( user, options = {} )
    if user and user.in?(self.members)
      time_of_unassignment = options[:at] || options[:time] || Time.zone.now
      UserGroupMembership.find_by(user: user, group: self).invalidate(at: time_of_unassignment)
    end
  end
  
  


  # Members
  # ==========================================================================================
  
  def members
    descendant_users
  end
  def direct_members
    child_users
  end
  
  
  # # Users
  # # ------------------------------------------------------------------------------------------
  # 
  # # These methods override the standard association methods for descendant_users
  # # and child_users to make sure that the `everyone` Groups do have *all* users
  # # as children and descendants.
  # #
  # def descendant_users
  #   if self.has_flag?( :everyone )
  #     return User.where(true)
  #   else
  #     return super 
  #   end
  # end
  # 
  # def child_users
  #   if self.has_flag?( :everyone )      
  #     return User.where(true)
  #   else
  #     return super
  #   end
  # end
  # 
  # 
  # 
  # # This returns a string of the titles of the direct members of this group. This is used
  # # for in-place editing, for example.
  # # 
  # # The string would be something like this:
  # # 
  # #    "#{user1.title}, #{user2.title}, ..."
  # #
  # def direct_member_titles_string
  #   child_users.collect { |user| user.title }.join( ", " )
  # end
  # 
  # # This sets the memberships of a group according to the given string of user titles.
  # # 
  # # For example, after calling
  # # 
  # #    direct_member_titles_string = "#{user1.title}, #{user2.title}",
  # # 
  # # the users `user1` and `user2` are the only direct members of the group.
  # # The memberships are removed using the standard methods, which means that the memberships
  # # are only marked as deleted. See: acts_as_paranoid_dag gem.
  # #
  # def direct_member_titles_string=( titles_string )
  #   new_members_titles = titles_string.split( "," )
  #   new_members = new_members_titles.collect do |title|
  #     u = User.find_by_title( title.strip )
  #     self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
  #     u
  #   end
  #   for member in child_users
  #     unassign_user member unless member.in? new_members if member
  #   end
  #   for new_member in new_members
  #     assign_user new_member if new_member
  #   end
  # end
  
  
end
