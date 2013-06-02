
# This module extends the Structureable models by methods for the interaction with roles.
# For example, a structureable object is being equipped with a `admins` association
# that lists all (direct) admin users of the object. To make a user an admin of a structureable
# object, you may call `object.admins << user`.
#
# This module is included by `include StructureableMixins::Roles`.
#
module StructureableMixins::Roles

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails

#    include StructureableMixins::HasSpecialGroup
#    has_special_group :officers_parent
#
#    # Admins
#    # ==========================================================================================
#    #
#    # This provides the following methods:
#    #   some_structureable.admins_parent
#    #                     .find_admins_parent_group
#    #                     .admins_parent!
#    #                     .find_or_create_admins_parent_group
#    #                     .create_admins_parent_group
#    #                     .admins  # returns an array of the admin users
#    #                     .admins << some_user
#    #
#    has_special_group :admins_parent, :child_of => :officers_parent
#
#    # Main Admins
#    # ==========================================================================================
#    #
#    # Main admins are also admins. But they have more rights and responsibilities.
#    # For example, they may edit the critical properties of the objects they administrate.
#    #
#    has_special_group :main_admins_parent, :child_of => :admins_parent

  end

end
