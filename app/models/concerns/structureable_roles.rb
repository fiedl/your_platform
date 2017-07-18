# This module extends the Structureable models by methods for the interaction with roles.
# For example, a structureable object is being equipped with a `admins` association
# that lists all (direct) admin users of the object. To make a user an admin of a structureable
# object, you may call `object.assign_admin user`.
#
concern :StructureableRoles do

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
    if self.ancestor_groups.reload.find_all_by_flag(:officers_parent).count == 0 and not self.has_flag?(:officers_parent)
      # Do not allow officer cascades.
      create_special_group(:officers_parent)
    end
  end

  def find_or_create_officers_parent_group
    find_officers_parent_group || create_officers_parent_group
  end

  def officers_parent
    find_or_create_officers_parent_group
  end

  def officers_parent!
    find_officers_parent_group || raise('special group :officers_parent does not exist.')
  end


  def descendant_officer_groups
    self.descendant_groups.where(type: 'OfficerGroup')
  end

  def create_officer_group(attrs = {name: "New Office"})
    g = officers_parent.child_groups.create(attrs)
    g.update_attribute :type, "OfficerGroup"
    return Group.find(g.id)  # in order to have it the OfficerGroup class
  end


  # This method returns all officer_parent groups of the structureable object itself
  # and of the descendant groups of the structureable object.
  #
  def find_officers_parent_groups_of_self_and_of_descendant_groups
    [self.find_officers_parent_group] + self.descendant_groups.find_all_by_flag(:officers_parent) - [nil]
  end

  # This method lists all officer groups of the group, i.e. all subgroups of the
  # officers_parent group.
  #
  def find_officers_groups
    self.find_officers_parent_group.try(:descendant_officer_groups) || []
  end
  def officers_groups
    self.officers_parent.descendant_officer_groups
  end

  def direct_officers
    self.find_officers_parent_group.try(:members) || []
  end

  def officers_of_self_and_parent_groups
    direct_officers + (parent_groups.collect { |parent_group| parent_group.direct_officers }.flatten)
  end

  def officers_groups_of_self_and_descendant_groups
    self.find_officers_parent_groups_of_self_and_of_descendant_groups.collect do |officers_parent|
      officers_parent.descendant_officer_groups
    end.flatten.uniq
  end

  def find_officers
    if respond_to? :child_groups
      find_officers_parent_group.try(:members)
    end || []
  end

  def officers_of_ancestors
    ancestors.collect { |ancestor| ancestor.find_officers }.flatten
  end

  def officers_of_ancestor_groups
    ancestor_groups.collect { |ancestor| ancestor.find_officers }.flatten
  end

  def officers_of_self_and_ancestors
    find_officers + officers_of_ancestors
  end

  def officers_of_self_and_ancestor_groups
    find_officers + officers_of_ancestor_groups
  end

  # This method returns all officer users, as well all of this group as of its subgroups.
  #
  def officers
    self.find_officers_parent_groups_of_self_and_of_descendant_groups.collect do |officers_parent|
      officers_parent.members
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
  #   my_structureable.assign_admin user
  #

  def find_admins_parent_group
    find_special_group(:admins_parent, parent_element: find_officers_parent_group )
  end

  def create_admins_parent_group
    delete_cached(:find_admins)
    create_special_group :admins_parent, parent_element: find_or_create_officers_parent_group, type: 'OfficerGroup'
  end

  def find_or_create_admins_parent_group
    find_special_group(:admins_parent, parent_element: find_or_create_officers_parent_group) or
    begin
      delete_cached(:find_admins)
      create_special_group :admins_parent, parent_element: find_or_create_officers_parent_group, type: 'OfficerGroup'
    rescue
      nil
    end
  end

  def admins_parent
    find_or_create_admins_parent_group
  end

  def admins_parent!
    find_admins_parent_group || raise('special group :admins_parent does not exist.')
  end

  def admins
    find_or_create_admins_parent_group.try(:members) || []
  end

  def assign_admin(user, options = {})
    admins_parent.assign_user user, options
  end

  def unassign_admin(user, options = {})
    admins_parent.unassign_user user, options
  end

  def find_admins
    if respond_to? :child_groups
      find_admins_parent_group.try(:members)
    end || []
  end

  def admins_of_ancestors
    ancestors.collect { |ancestor| ancestor.find_admins }.flatten
  end

  def admins_of_ancestor_groups
    ancestor_groups.collect { |ancestor| ancestor.find_admins }.flatten
  end

  def admins_of_self_and_ancestors
    find_admins + admins_of_ancestors
  end

  def local_admins
    (admins_of_self_and_ancestors - global_admins).uniq
  end

  def global_admins
    Role.global_admins
  end

  def responsible_admins
    if local_admins.any?
      local_admins
    elsif Role.non_technical_global_admins.any?
      Role.non_technical_global_admins
    else
      Role.global_admins
    end
  end
  def responsible_admin
    responsible_admins.first
  end
  def responsible_admin_id
    responsible_admin.try(:id)
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
  #   my_structureable.main_assign_admin user
  #

  def find_main_admins_parent_group
    find_special_group(:main_admins_parent, parent_element: find_admins_parent_group)
  end

  def create_main_admins_parent_group
    create_special_group :main_admins_parent, parent_element: find_or_create_admins_parent_group, type: 'OfficerGroup'
  end

  def find_or_create_main_admins_parent_group
    find_or_create_special_group :main_admins_parent, parent_element: find_or_create_admins_parent_group, type: 'OfficerGroup'
  end

  def main_admins_parent
    find_or_create_main_admins_parent_group
  end

  def main_admins_parent!
    find_main_admins_parent_group || raise('special group :main_admins_parent does not exist.')
  end

  def main_admins
    main_admins_parent.members
  end

  def assign_main_admin(user, options = {})
    main_admins_parent.assign_user user, options
  end

end
