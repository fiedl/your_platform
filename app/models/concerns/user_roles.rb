concern :UserRoles do
  
  # Roles and Rights
  # ==========================================================================================

  # This method returns the role the user (self) has for a given
  # structureable object.
  #
  # The roles may be :member, :admin or :main_admin.
  #
  def role_for( structureable )
    return nil if not structureable.respond_to? :parent_groups
    return :main_admin if self.main_admin_of? structureable
    return :admin if self.admin_of? structureable
    return :member if self.member_of? structureable
  end
  
  # Member Status
  # ------------------------------------------------------------------------------------------
  
  # This method is a dirty hack to preserve the obsolete role model mechanism, 
  # which is currently not in use, since the abilities are defined directly in the 
  # Ability class.
  #
  # Options:
  # 
  #   with_invalid, also_in_the_past : true/false
  #
  # TODO: refactor it together with the role model mechanism.
  #
  def member_of?( object, options = {} )
    if object.kind_of? Group
      if options[:with_invalid] or options[:also_in_the_past]
        self.ancestor_group_ids.include? object.id
      else  # only current memberships:
        self.group_ids.include? object.id  # This uses the validity range mechanism
      end
    else
      self.ancestors.include? object
    end
  end

  # Admins
  # ------------------------------------------------------------------------------------------

  def admin_of_anything?
    cached { groups.find_all_by_flag(:admins_parent).count > 0 }
  end

  # This method finds all objects the user is an administrator of.
  #
  def admin_of
    self.administrated_objects
  end

  # This method verifies if the user is administrator of the given structureable object.
  #
  def admin_of?( structureable )
    self.admin_of.include? structureable
  end

  # This method returns all structureable objects the user is directly administrator of,
  # i.e. the user is a member of the administrators group of this object.
  #
  def directly_administrated_objects( role = :admin )
    admin_group_flag = :admins_parent if role == :admin
    admin_group_flag = :main_admins_parent if role == :main_admin
    admin_groups = self.ancestor_groups.find_all_by_flag( admin_group_flag )
    if admin_groups.count > 0
      objects = admin_groups.collect do |admin_group|
        admin_group.administrated_object
      end
    else
      []
    end
  end

  # This method returns all structureable objects the user is administrator of.
  #
  def administrated_objects( role = :admin )
    objects = directly_administrated_objects( role )
    if objects
      objects += objects.collect do |directly_administrated_object|
        directly_administrated_object.descendants
      end.flatten
      objects
    else
      []
    end
  end

  # Main Admins
  # ------------------------------------------------------------------------------------------

  # This method says whether the user (self) is a main admin of the given
  # structureable object.
  #
  def main_admin_of?( structureable )
    self.administrated_objects( :main_admin ).include? structureable
  end


  # Guest Status
  # ==========================================================================================

  # This method says if the user (self) is a guest of the given group.
  #
  def guest_of?( group )
    return false if not group.find_guests_parent_group
    group.guests.include? self
  end

  # Former Member
  # ==========================================================================================

  def former_member_of_corporation?( corporation )
    corporation.becomes(Corporation).former_members.include? self
  end


  # Developer Status
  # ==========================================================================================

  # This method returns whether the user is a developer. This is needed, for example, 
  # to determine if some features are presented to the current_user. 
  # 
  def developer?
    cached { self.developer }
  end
  def developer
    self.member_of? Group.developers
  end
  def developer=( mark_as_developer )
    if mark_as_developer
      Group.developers.assign_user self
    else
      Group.developers.unassign_user self
    end
  end
  
  # Beta Tester Status
  # ==========================================================================================
  
  def beta_tester?
    @beta_tester ||= self.beta_tester
  end
  def beta_tester
    cached { self.member_of? Group.find_or_create_by_flag :beta_testers }
  end
  def beta_tester=(mark_as_beta_tester)
    if mark_as_beta_tester
      Group.find_or_create_by_flag(:beta_testers).assign_user self
    else
      Group.find_or_create_by_flag(:beta_testers).child_users.destroy(self)
    end
  end
  
  # Global Admin Switch
  # ==========================================================================================

  def global_admin
    self.in? Group.everyone.admins
  end
  def global_admin?
    cached { self.global_admin }
  end
  def global_admin=(new_setting)
    if new_setting == true
      Group.everyone.admins << self
    else
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.main_admins_parent).try(:destroy)
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.admins_parent).try(:destroy)
    end
  end
  

  # Officers
  # ==========================================================================================
  
  def officer_of_anything?
    self.groups.detect { |g| g.type == 'OfficerGroup' } || false
  end


  # Methods transferred from former Role class
  # ==========================================================================================

  def global_officer?
    is_global_officer?
  end

  def is_global_officer?
    cached { global_admin? || ancestor_groups.flagged(:global_officer).exists? }
  end

  def administrated_user_ids
    groups.flagged(:admins_parent).collect{ |g| g.parent_groups.first.parent_groups.first }.compact.collect{ |g| g.descendant_users.pluck(:id) }.flatten
  end

  def administrates_user?(id)
    groups.flagged(:admins_parent).each do |g|
      user_group = g.parent_groups.first.parent_groups.first
      return true if user_group && user_group.descendant_users.exists?(id)
    end
    return false
  end
  
  
end