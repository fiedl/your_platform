#
# There are certain gloabl special groups, for example the `everyone` group, which contains
# all users.
#
# The mechanism used by this mixin is defined in `StructureableMixins::HasSpecialGroups`.
#
module GroupMixins::HiddenUsers

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end

  # Hidden Users
  # ==========================================================================================
  #
  # This group contains all users that are hidden to normal users and only visible
  # to their administrators.
  #
  module ClassMethods
    def find_hidden_users_group
      find_special_group(:hidden_users)
    end

    def create_hidden_users_group
      create_special_group(:hidden_users)
    end

    def find_or_create_hidden_users_group
      find_or_create_special_group(:hidden_users)
    end

    def hidden_users
      find_or_create_hidden_users_group
    end

    def hidden_users!
      find_hidden_users_group || raise(ActiveRecord::RecordNotFound, 'special group :hidden_users does not exist.')
    end
  end

end
