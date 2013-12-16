#
# There are certain gloabl special groups, for example the `everyone` group, which contains
# all users.
#
# The global accessors for these groups, e.g. `Group.find_everyone_group` or 
# `Group.everyone` for short, are defined in this mixin.
#
# The mechanism used by this mixin is defined in `StructureableMixins::HasSpecialGroups`.
#
module GroupMixins::Everyone

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end

  # Everyone Group
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
  
  
  # Members
  # ==========================================================================================
  
  # This method overrides the default association to emulate the bahaviour that really every
  # user is member of the :everyone group.
  #
  def members
    if self.has_flag? :everyone
      User.where(true)
    else
      super
    end
  end
  
  # This method overrides the default association to emulate the bahaviour that really every
  # user is direct member of the :everyone group.
  #
  def direct_members
    if self.has_flag? :everyone
      User.where(true)
    else
      super
    end
  end
  
end
