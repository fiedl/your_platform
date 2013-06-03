
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
  end
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails

#    include StructureableMixins::HasSpecialGroup


  # Officers
  # ==========================================================================================

#    has_special_group :officers_parent

        

  def find_officers_parent_group
    find_special_group(:officers_parent)
  end
  
  def create_officers_parent_group
    create_special_group(:officers_parent)
  end
  
  def find_or_create_officers_parent_group
    find_or_create_special_group(:officers_parent)
  end
  
  def officers_parent
    find_or_create_officers_parent_group
  end
  
  def officers_parent!
    find_officers_parent_group || raise('special group :officers_parent does not exist.')
  end
  
  def officers
    officers_parent.descendant_users
  end
  


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

    def find_admins_parent_group
      find_special_group(:admins_parent, parent_element: find_officers_parent_group )
    end

    def create_admins_parent_group
      create_special_group(:admins_parent, parent_element: find_or_create_officers_parent_group )
    end

    def find_or_create_admins_parent_group
      find_or_create_special_group(:admins_parent, parent_element: find_or_create_officers_parent_group )
    end

    def admins_parent
      find_or_create_admins_parent_group
    end

    def admins_parent!
      find_admins_parent_group || raise('special group :admins_parent does not exist.')
    end

    def admins
      admins_parent.descendant_users
    end

#
#    # Main Admins
#    # ==========================================================================================
#    #
#    # Main admins are also admins. But they have more rights and responsibilities.
#    # For example, they may edit the critical properties of the objects they administrate.
#    #
#    has_special_group :main_admins_parent, :child_of => :admins_parent

    def find_main_admins_parent_group
      find_special_group(:main_admins_parent, parent_element: find_admins_parent_group)
    end

    def create_main_admins_parent_group
      create_special_group(:main_admins_parent, parent_element: find_or_create_admins_parent_group )
    end

    def find_or_create_main_admins_parent_group
      find_or_create_special_group(:main_admins_parent, parent_element: find_or_create_admins_parent_group )
    end

    def main_admins_parent
      find_or_create_main_admins_parent_group
    end

    def main_admins_parent!
      find_main_admins_parent_group || raise('special group :main_admins_parent does not exist.')
    end

    def main_admins
      main_admins_parent.descendant_users
    end





end
