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
    # return :main_admin if self.main_admin_of? structureable
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
      if options[:at]
        Membership.find_all_by(user: self, group: object).at_time(options[:at]).any?
      elsif options[:with_invalid] or options[:also_in_the_past]
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
    groups.find_all_by_flag(:admins_parent).count > 0
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

  def directly_administrated_objects
    Role.of(self).directly_administrated_objects
  end

  def administrated_objects
    Role.of(self).administrated_objects
  end


  # # Main Admins
  # # ------------------------------------------------------------------------------------------
  #
  # # This method says whether the user (self) is a main admin of the given
  # # structureable object.
  # #
  # def main_admin_of?( structureable )
  #   self.administrated_objects( :main_admin ).include? structureable
  # end


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

  def former_member?
    current_corporations.none? && corporations.any?
  end

  def former_member_of_corporation?( corporation )
    corporation.becomes(Corporation).former_members.include? self
  end

  def date_of_org_membership_end
    memberships.with_past.find_by(ancestor_id: Group.main_org.id, ancestor_type: 'Group').try(:valid_to).try(:to_date)
  end

  def localized_date_of_org_membership_end
    I18n.localize date_of_org_membership_end if date_of_org_membership_end
  end

  def reason_for_membership_end
    if dead?
      I18n.t(:deceased)
    else
      status_string
    end
  end


  # Developer Status
  # ==========================================================================================

  # This method returns whether the user is a developer. This is needed, for example,
  # to determine if some features are presented to the current_user.
  #
  def developer?
    self.developer
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
    self.member_of? Group.find_or_create_by_flag :beta_testers
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
    self.global_admin
  end
  def global_admin=(new_setting)
    if new_setting == true
      Group.everyone.assign_admin self
    else
      Membership.find_by_user_and_group(self, Group.everyone.main_admins_parent).try(:destroy)
      Membership.find_by_user_and_group(self, Group.everyone.admins_parent).try(:destroy)
    end
  end


  # Officers
  # ==========================================================================================

  def officer_of_anything?
    self.groups.detect { |g| g.type == 'OfficerGroup' } || false
  end

  def corporations_the_user_is_officer_in
    Corporation.where(id: self.groups.where(type: 'OfficerGroup').collect { |g| g.ancestor_group_ids }.flatten.uniq)
  end

  def primarily_administrated_corporation
    if global_admin?
      primary_corporation
    else
      (corporations_the_user_is_officer_in & [primary_corporation]).first
    end
  end

  def corporations_the_user_can_represent
    if global_admin?
      Corporation.all
    else
      corporations_the_user_is_officer_in
    end
  end

  def page_ids_of_pages_the_user_is_officer_of
    self.groups.where(type: "OfficerGroup").collect(&:scope).select { |scope| scope.kind_of?(Page) }.collect { |page| page.sub_page_ids }.flatten.uniq
  end

  def pages_the_user_is_officer_of
    Page.where(id: page_ids_of_pages_the_user_is_officer_of)
  end


  # Methods transferred from former Role class
  # ==========================================================================================

  def global_officer?
    global_admin? || ancestor_groups.flagged(:global_officer).exists?
  end

  def is_global_officer?
    global_officer?
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