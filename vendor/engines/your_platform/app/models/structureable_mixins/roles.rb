#
# This module extends the Structureable models by methods for the interaction with roles.
# For example, a structureable object is being equipped with a `admins` association
# that lists all (direct) admin users of the object. To make a user an admin of a structureable
# object, you may call `object.admins << user`.
#
# This module is included by `include StructureableMixins::Roles`.
#
# The helper methods used in the module are defined in `StructureableMixins::HasSpecialGroups`.
#
module StructureableMixins::Roles

  extend ActiveSupport::Concern

  included do
  end


  # Officers
  # ==========================================================================================
  #
  # Each structureable object may have officers, e.g. the president of the organization.
  # Officers are collected in a subgroup with the flag :officers_parent. This
  # officers_parent group may also have subgroups. But, of course, the officers_parent
  # group must not have another officers_parent subgroup.
  #
  # Calling `some_structureable_object.officers` lists all officer users of the structureable
  # itself **and of the sub groups** of the structureable object.
  #

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

  # This method returns all officer_parent groups of the structureable object itself
  # and of the descendant groups of the structureable object.
  #
  def find_officers_parent_groups_of_self_and_of_descendant_groups
    officers_parent_groups = ( [self] + self.descendant_groups ).collect do |group|
      group.find_special_group(:officers_parent)
    end.select { |group| group.present? }
  end

  # This method lists all officer groups of the group, i.e. all subgroups of the
  # officers_parent group.
  #
  def find_officers_groups
    self.officers_parent.descendant_groups
  end

  # This method returns all officer users, as well all of this group as of its subgroups.
  #
  def officers
    self.find_officers_parent_groups_of_self_and_of_descendant_groups.collect do |officers_parent|
      officers_parent.descendant_users
    end.flatten.uniq
  end


  # Admins
  # ==========================================================================================
  #
  # Each structureable object may have admins (users), which are collected in the
  # `admins_parent` special group of the structureable object, which is a subgroup
  # of the officers_parent subgroup of the structureable object.
  #
  #     my_structureable
  #             |----------- officers_parent
  #                                |----------- admins_parent
  #
  # One can access or assign the admins of the structureable object by calling:
  #
  #   my_structureable.admins          # => Array of users
  #   my_structureable.admins << user
  #

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
    if admins_parent
      admins_parent.descendant_users
    else
      []
    end
  end

  def find_admins
    unless find_admins_parent_group.nil?
      find_admins_parent_group.descendant_users
    else
      []
    end
  end


  # Main Admins
  # ==========================================================================================
  #
  # Main admins are also admins. But they have more rights and responsibilities.
  # For example, they may edit the critical properties of the objects they administrate.
  #
  # Since main admins are also admins, the special group structure looks like this:
  #
  #     my_structureable
  #             |----------- officers_parent
  #                                |----------- admins_parent
  #                                                 |---------- main_admins_parent
  #
  # One can access or assign the main admins of the structureable object by calling:
  #
  #   my_structureable.main_admins          # => Array of users
  #   my_structureable.main_admins << user
  #

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
