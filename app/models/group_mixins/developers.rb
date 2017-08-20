#
# There are certain gloabl special groups, for example the `developers` group, which contains
# all users.
#
# The global accessors for these groups, e.g. `Group.find_developers_group` or
# `Group.developers` for short, are defined in this mixin.
#
# The mechanism used by this mixin is defined in `StructureableMixins::HasSpecialGroups`.
#
module GroupMixins::Developers

  extend ActiveSupport::Concern

  # Developers
  # ==========================================================================================
  #
  # The group where all developers are members of.
  #
  module ClassMethods
    def find_developers_group
      find_special_group(:developers)
    end

    def create_developers_group
      create_special_group(:developers)
    end

    def find_or_create_developers_group
      find_or_create_special_group(:developers)
    end

    def developers
      find_or_create_developers_group
    end

    def developers!
      find_developers_group || raise(ActiveRecord::RecordNotFound'special group :developers does not exist.')
    end
  end

end
