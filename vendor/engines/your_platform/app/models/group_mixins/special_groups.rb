
# This module extends the Group model by methods for the interaction with so called 'special groups'.
# Those special groups are, for example, the group 'everyone' or the 'officers' groups, which are
# subgroups of each group which can have officers. 
# 
# The module is included in the Group model by `include GroupMixins::Special Groups`.
# The methods of the module can be accessed just like any other Group model methods:
#    Group.class_method()
#    g = Group.new()
#    g.instance_method()
#
module GroupMixins::SpecialGroups

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails


    # Everyone
    # ==========================================================================================
    #
    # The 'root group', which is the highest in the group hierarchy. 
    # Everyone is member of this group, even not registered users.
    # 
    # This creates the methods
    #    Group.everyone
    #    Group.find_everyone_group
    #    Group.everyone!
    #    Group.find_or_create_everyone_group
    #    Group.create_everyone_group
    #
    has_special_group :everyone, global: true     # or: `Group.has_special_group(...)` outside of `included`.


    # Corporations Parent
    # ==========================================================================================
    #
    # Parent group for all corporation groups.
    # The group structure looks something like this:
    #
    #   everyone
    #      |----- corporations_parent                     <--- this is the group returned by this method
    #                       |---------- corporation_a
    #                       |                |--- ...
    #                       |---------- corporation_b
    #                       |                |--- ...
    #                       |---------- corporation_c
    #                                        |--- ...
    #
    has_special_group :corporations_parent, global: true 

    # Officers Parent
    # ==========================================================================================
    #
    # Each group may have officers, e.g. the president of the organization.
    # Officers are collected in a sub-group with the flag :officers_parent. This 
    # officers_parent-group may also have sub-groups. But, of course, the officers_parent 
    # group must not have another officers_parent sub-group.
    # 
    # This provides the following methods:
    #     officers_parent
    #     officers_parent!
    #     officers
    #     find_officers_parent_group
    #     create_officers_parent_group
    #     find_or_create_officers_parent_group
    #
    has_special_group :officers_parent

    # This method returns all officer users, as well all of this group as of its sub-groups.
    # Therefore, this method has to be overridden, since the one provided by
    # `has_special_group :officers_parent` would return only the officers of this group.
    #
    def officers
      find_officers_groups.collect do |officers_group|
        officers_group.descendant_users
      end.flatten.uniq
    end


    # Guests Parent
    # ==========================================================================================
    #
    # As well as officers, each group may have guests.
    #
    # This provides the following methods:
    # guests_parent
    # guests_parent!
    # guests
    # find_guests_parent_group
    # create_guests_parent_group
    # find_or_create_guests_parent_group
    #
    has_special_group :guests_parent

  end

  
  # Corporations
  # ==========================================================================================

  module ClassMethods

    # Find all corporation groups, i.e. the children of `corporations_parent`.
    # Alias method for `find_corporation_groups`.
    #
    def corporations
      find_corporation_groups
    end

    # Find all corporation groups, i.e. the children of `corporations_parent`.
    #
    def find_corporation_groups
      if self.corporations_parent
        self.corporations_parent.child_groups
      else
        []
      end
    end

    # Find corporation groups of a certain user.
    #
    def find_corporation_groups_of( user )
      ancestor_groups_of_user = user.ancestor_groups
      corporation_groups = Group.find_corporation_groups if Group.find_corporations_parent_group
      return ancestor_groups_of_user & corporation_groups if ancestor_groups_of_user and corporation_groups
    end

    # Find corporation groups of a certain user.
    # Alias method of `find_corporation_groups_of`.
    #
    def corporations_of( user )
      self.find_corporation_groups_of user
    end

    # Find all groups of the corporations branch, i.e. the corporations_parent
    # and its descendant groups.
    # 
    #   everyone
    #      |----- corporations_parent                      <
    #      |                |---------- corporation_a      <  These groups are returned
    #      |                |                |--- ...      <  by this method.
    #      |                |---------- corporation_b      <  
    #      |                                 |--- ...      <
    #      |----- other_group_1
    #      |----- other_group_2
    def find_corporations_branch_groups
      if Group.corporations_parent
        return [ Group.corporations_parent ] + Group.corporations_parent.descendant_groups
      end
    end

    # Find all groups of the corporations branch of a certain user, i.e. all corporations
    # of a user and the descendant groups of these corporations.
    #
    # This is used, for example, in the my-groups view, where the corporations groups
    # are displayed separately.
    #
    def find_corporations_branch_groups_of( user )
      ancestor_groups = user.ancestor_groups
      corporations_branch = self.find_corporations_branch_groups
      return ancestor_groups & corporations_branch if ancestor_groups and corporations_branch
    end

    # Find all groups of a certain user that are not part of the user's corporations_branch,
    # see `self.find_corporations_branch_groups_of`.
    #
    # This is used, for example, in the my-groups view, where the corporations groups
    # are displayed separately.
    #
    def find_non_corporations_branch_groups_of( user )
      ancestor_groups = user.ancestor_groups
      corporations_branch = self.find_corporations_branch_groups
      corporations_branch = [] unless corporations_branch
      return ancestor_groups - corporations_branch
    end

  end


  # Officers Parent
  # ==========================================================================================

  # This method lists all officer groups, as well in this group as well all of the sub-groups.
  # The method name is not to be confused with `find_officers_parent_group`, 
  # which is provided by `has_special_group :officers_parent`.
  #
  def find_officers_groups
    officers_parents = self.descendant_groups.find_all_by_flag( :officers_parent )
    officers = officers_parents.collect{ |officer_group| officer_group.child_groups }.flatten
    return officers # if officers.count > 0
  end

  # Officers somehow administrate structureable objects, e.g. groups or pages.
  # They may be admins, main_admins, editors or another kind of officer.
  # 
  # This method returns the object that is administrated by the officers that are in this
  # group (self) if this is an officer group.
  #
  #     some_group
  #         |------- another_group   <---------------------------- this group is returned
  #                        |-------- officers
  #                                      |---- admins
  #                                               |--- main_admins
  #
  #     main_admins.administrated_object == another_group
  #     admins.administrated_object == another_group
  #     officers.administrated_object == another_group
  #     another_group.administrated_object == nil
  #     some_group.administrated_object == nil
  #
  def administrated_object
    if self.ancestor_groups.find_all_by_flag( :officers_parent ).count == 0 and
        not self.has_flag? :officers_parent
      return nil
    end
    object = self
    until object.has_flag? :officers_parent
      object = object.parents.first
    end
    object = object.parents.first
  end
   
 
  # Guests Parent
  # ==========================================================================================

  # This method lists all guest sub-groups of self, but not of the sub-groups of self.
  #
  def find_guests_groups
    find_guests_parent_group.descendant_groups
  end

  # This method lists all descendant users of the guests_parent_group.
  #
  def find_guest_users
    guests
  end

end
