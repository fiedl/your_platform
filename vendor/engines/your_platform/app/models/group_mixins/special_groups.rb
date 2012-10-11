
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
  end


  # Everyone
  # ==========================================================================================

  module ClassMethods

    # The 'root group', which is the highest in the group hierarchy. 
    # Everyone is member of this group, even not registered users.
    # 
    def everyone
      self.find_everyone_group
    end
    
    def find_everyone_group
      Group.find_by_flag( :everyone )
    end

    def create_everyone_group
      everyone = Group.create( name: 'Everyone' )
      everyone.add_flag( :everyone )
      everyone.name = I18n.translate( :everyone )
      everyone.save
      return everyone
    end
    
  end


  # Corporations Parent
  # ==========================================================================================

  module ClassMethods

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
    def corporations_parent
      self.find_corporations_parent_group
    end
    
    def find_corporations_parent_group
      Group.find_by_flag( :corporations_parent )
    end

    def create_corporations_parent_group
      corporations_parent = Group.create( name: "Corporations" )
      corporations_parent.add_flag( :corporations_parent )
      corporations_parent.parent_groups << Group.everyone
      corporations_parent.name = I18n.translate( :corporations_parent )
      corporations_parent.save
      return corporations_parent
    end

  end

  
  # Corporations
  # ==========================================================================================
  
  module ClassMethods

    # Find all corporation groups, i.e. the children of `corporations_parent`.
    # Alias method for `find_corporation_groups`.
    #
    def corporations
      self.find_corporation_groups
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

  # Each group may have officers, e.g. the president of the organization.
  # Officers are collected in a sub-group with the flag :officers_parent. This 
  # officers_parent-group may also have sub-groups. But, of course, the officers_parent 
  # group must not have another officers_parent sub-group.
  # 
  extend HasSpecialChildParentGroup
  has_special_child_parent_group :officers

  # This provides the following methods:
  # officers_parent
  # officers_parent!
  # officers
  # find_officers_parent_group
  # create_officers_parent_group
  # find_officers_groups

  # This finder method has to be overridden, since we want to have a special behaviour
  # for officers: All officers of sub-groups of self should be listed as officers of 
  # self, too.
  #
  def find_officers_groups
    officers_parents = self.descendant_groups.find_all_by_flag( :officers_parent )
    officers = officers_parents.collect{ |officer_group| officer_group.child_groups }.flatten
    return officers # if officers.count > 0
  end


  # Guests Parent
  # ==========================================================================================

  # As well as officers, each group may have guests.
  #
  has_special_child_parent_group :guests

  # This provides the following methods:
  # guests_parent
  # guests_parent!
  # guests
  # find_guests_parent_group
  # create_guests_parent_group
  # find_guests_groups

  def find_guest_users
    if self.find_guests_parent_group
      self.find_guests_parent_group.descendant_users 
    else
      []
    end
  end

  # In contrast to officers, `group.guests` should list all guest USERS, not
  # all officers groups.
  #
  def guests
    self.find_guest_users
  end

end
