
module GroupMixins::GlobalSpecialGroups

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end

  # Everyone
  # ==========================================================================================
  #
  # The 'root group', which is the highest in the group hierarchy.
  # Everyone is member of this group, even not registered users.
  #

  module ClassMethods
    def find_everyone_group
      find_special_group(:everyone)
    end
    
    def create_everyone_group
      create_special_group(:everyone)
    end

    def find_or_create_everyone_group
      find_or_create_special_group(:everyone)
    end
    
    def everyone
      find_or_create_everyone_group
    end
    
    def everyone!
      find_everyone_group || raise('special group :everyone does not exist.')
    end
  end


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

  module ClassMethods
    def find_corporations_parent_group
      find_special_group(:corporations_parent)
    end
    
    def create_corporations_parent_group
      create_special_group(:corporations_parent)
    end
    
    def find_or_create_corporations_parent_group
      find_or_create_special_group(:corporations_parent)
    end
    
    def corporations_parent
      find_or_create_corporations_parent_group
    end
    
    def corporations_parent!
      find_corporations_parent_group || raise('special group :corporations_parent does not exist.')
    end
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



end
