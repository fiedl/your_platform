# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account, :female, :add_to_group,
                            :add_to_corporation, :date_of_birth, :localized_date_of_birth

  attr_accessor             :create_account, :add_to_group, :add_to_corporation
  # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :first_name, :last_name
  validates_uniqueness_of   :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of       :email, :with => /\A[a-z0-9_.-]+@[a-z0-9.-]+\.[a-z.]+\z/i, :if => Proc.new { |user| user.email.present? }

  has_profile_fields        profile_sections: [:contact_information, :about_myself, :study_information, :career_information,
     :organizations, :bank_account_information]

  # TODO: This is already Rails 4 syntax. Use this when we switch to Rails 4.
  # http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
  #
  # has_one                   :date_of_birth_profile_field, -> { where label: 'date_of_birth' }, class_name: "ProfileFieldTypes::Date", as: :profileable, autosave: true
  #
  # The old Rails 3.2 syntax would be:
  #
  # has_one                   :date_of_birth_profile_field, class_name: "ProfileFieldTypes::Date", conditions: "label = 'date_of_birth'", as: :profileable, autosave: true
  #
  # But on build_date_of_birth_profile_field the condition is not set automatically. There are some other issues with this behaviour.
  # We would still have to use an instance variable. Therefore, we just build the association from scratch.
  # See code down at #date_of_birth_profile_field.
  #
  after_save                :save_date_of_birth_profile_field

  has_one                   :account, class_name: "UserAccount", autosave: true, inverse_of: :user, dependent: :destroy
  validates_associated      :account

  delegate                  :send_welcome_email, :to => :account

  is_structureable          ancestor_class_names: %w(Page Group), descendant_class_names: %w(Page)

  has_many                  :relationships_as_first_user, foreign_key: 'user1_id', class_name: "Relationship", dependent: :destroy, inverse_of: :user1

  has_many                  :relationships_as_second_user, foreign_key: 'user2_id', class_name: "Relationship", dependent: :destroy, inverse_of: :user2

  has_many                  :bookmarks

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name
  before_save               :build_account_if_requested
  after_save                :add_to_group_if_requested
  
  
  # Mixins
  # ==========================================================================================
  
  include UserMixins::Memberships
  include UserMixins::Identification

  # General Properties
  # ==========================================================================================

  # The name of the user, i.e. first_name and last_name.
  #
  def name
    first_name + " " + last_name if first_name && last_name
  end

  # This method will make the first_name and the last_name capitalized.
  # For example:
  #
  #   @user = User.create( first_name: "john", last_name: "doe", ... )
  #   @user.capitalize_name  # => "John Doe"
  #   @user.save
  #   @user.name  # => "John Doe"
  #
  def capitalize_name
    self.first_name = capitalized_name_string( self.first_name )
    self.last_name = capitalized_name_string( self.last_name )
    self.name
  end

  def capitalized_name_string( name_string )
    return name_string if name_string.include?( " " )
    return name_string.slice( 0, 1 ).capitalize + name_string.slice( 1 .. -1 )
  end
  private :capitalized_name_string

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  #
  def title
    name
  end

  # This accessors allow to access the gender of the user rather than just asking if the
  # user is female as allowed by the ActiveRecord accessor.
  # (:female is a boolean column in the users table.)
  #
  def gender
    return :female if female?
    return :male
  end
  def gender=( new_gender )
    if new_gender.to_s == "female"
      self.female = true
    else
      self.female = false
    end
  end

  # Date of Birth
  #
  def date_of_birth
    date_of_birth_profile_field.value.to_date if date_of_birth_profile_field.value if date_of_birth_profile_field
  end
  def date_of_birth=( date_of_birth )
    find_or_build_date_of_birth_profile_field.value = date_of_birth
  end

  def date_of_birth_profile_field
    @date_of_birth_profile_field ||= profile_fields.where( type: "ProfileFieldTypes::Date", label: 'date_of_birth' ).limit(1).first
  end
  def build_date_of_birth_profile_field
    raise 'profile field already exists' if date_of_birth_profile_field
    @date_of_birth_profile_field = profile_fields.build( type: "ProfileFieldTypes::Date", label: 'date_of_birth' )
  end

  def find_or_build_date_of_birth_profile_field
    date_of_birth_profile_field || build_date_of_birth_profile_field
  end
  def save_date_of_birth_profile_field
    date_of_birth_profile_field.try(:save)
  end
  private :save_date_of_birth_profile_field
  
  def find_or_create_date_of_birth_profile_field
    date_of_birth_profile_field || ( build_date_of_birth_profile_field.save && date_of_birth_profile_field)
  end

  def localized_date_of_birth
    I18n.localize self.date_of_birth if self.date_of_birth
  end
  def localized_date_of_birth=(str)
    begin
      self.date_of_birth = str.to_date
    rescue
      self.date_of_birth = nil
    end
  end
  
  def age
    now = Time.now.utc.to_date
    dob = self.date_of_birth
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
  
  
  # Date of Death
  #
  def date_of_death
    profile_fields.where(label: 'date_of_death').first.try(:value)
  end
  def set_date_of_death_if_unset(new_date_of_death)
    new_date_of_death = I18n.localize(new_date_of_death.to_date)
    unless self.date_of_death
      profile_fields.create(type: "ProfileFieldTypes::General", label: 'date_of_death', value: new_date_of_death)
    end
  end
  def dead?
    date_of_death ? true : false
  end
  def alive?
    not dead?
  end
  
  # Example:
  # 
  #   user.mark_as_deceased at: "2014-03-05".to_datetime
  #
  def mark_as_deceased(options = {})
    date = options[:at] || Time.zone.now
    self.current_corporations.each do |corporation|
      self.current_status_membership_in(corporation).move_to corporation.deceased, at: date
    end
    end_all_non_corporation_memberships at: date
    set_date_of_death_if_unset(date)
  end
  
  def end_all_non_corporation_memberships(options = {})
    date = options[:at] || Time.zone.now
    for group in (self.direct_groups - Group.corporations_parent.descendant_groups)
      UserGroupMembership.find_by_user_and_group(self, group).invalidate at: date
    end
  end
  

  # Primary Postal Address
  #
  def postal_address_field
    self.profile_fields.where(type: "ProfileFieldTypes::Address").select do |address_field|
      address_field.postal_address? == true
    end.first
  end
  
  # Primary Postal Address or, if not existent, the first address field.
  #
  def postal_address_field_or_first_address_field
    postal_address_field || profile_fields.where(type: "ProfileFieldTypes::Address").first
  end

  # This method returns the postal address of the user.
  # If one address of the user has got a :postal_address flag, this address is used.
  # Otherwise, the first address of the user is used.
  #
  def postal_address
    postal_address_field_or_first_address_field.try(:value)
  end
  
  
  # Other infos from profile fields
  # ------------------------------------------------------------------------------------------

  def personal_title
    profile_fields.where(label: 'personal_title').first.try(:value).try(:strip)
  end
  def academic_degree
    profile_fields.where(label: 'academic_degree').first.try(:value).try(:strip)
  end




  # Associated Objects
  # ==========================================================================================

  # Alias
  # ------------------------------------------------------------------------------------------

  # The UserAlias class inherits from String, but has some more methods, e.g. a method
  # to generate a new alias from other user attributes. To make sure that `alias` returns
  # an object of UserAlias type, the accessor methods are overridden here.
  #
  def alias
    UserAlias.new(super) if super.present?
  end

  def generate_alias
    UserAlias.generate_for(self)
  end

  def generate_alias!
    self.alias = self.generate_alias
  end

  def generate_alias_if_necessary
    self.generate_alias! if self.alias.blank?
  end
  private :generate_alias_if_necessary


  # User Account
  # ------------------------------------------------------------------------------------------

  # A user stored in the database does not necessarily possess the right to log in, i.e.
  # have a user account. This method allows to find out whether the user has got an
  # active user account.
  #
  def has_account?
    return true if self.account
    return false
  end
  def has_no_account?
    not self.account.present?
  end

  # This method activates the user account, i.e. grants the user the right to log in.
  #
  def activate_account
    unless self.account
      self.account = self.build_account
      self.save
    end
    return self.account
  end

  # This method deactivates the user account, i.e. destroys the associated object
  # and prevents the user from logging in.
  #
  def deactivate_account
    raise "no user account exists, therefore it can't be destroyed." if not self.account
    self.account.destroy
    self.account = nil
  end

  # If the attribute `create_account` is set to `true` or to `1`, e.g. by an html form,
  # this code makes sure that the account association is build.
  # This code is run on validation, as you can see above in this model.
  # Note: A welcome email is automatically sent on save by the UserAccount model.
  def build_account_if_requested

    # If this value is set by an html form, it is "0" or "1". But "0" would
    # transform to true rather than to false.
    # Thus, we have to make sure that "0" means false.
    self.create_account = false if self.create_account == "0"
    self.create_account = true if self.create_account == "1"
    self.create_account = false if self.create_account == 0
    self.create_account = true if self.create_account == 1
    self.create_account = false if self.create_account == ""

    if self.create_account == true
      self.account.destroy if self.has_account?
      self.account = self.build_account
      self.create_account = false # to make sure that this code is nut run twice.
      return self.account
    end

  end
  private :build_account_if_requested


  # Groups
  # ------------------------------------------------------------------------------------------

  def add_to_group_if_requested
    if self.add_to_group
      group = add_to_group if add_to_group.kind_of? Group
      group = Group.find( add_to_group ) if add_to_group.to_i unless group
      UserGroupMembership.create( user: self, group: group ) if group
    end
    unless self.add_to_corporation.blank?
      corporation = add_to_corporation if add_to_corporation.kind_of? Group
      corporation ||= Group.find( add_to_corporation ) if add_to_corporation.to_i
      if corporation
        #
        # TODO: Move to wingolfsplattform. THIS IS WINGOLF SPECIFIC!!
        #
        hospitanten_group = corporation.descendant_groups.where(name: "Hospitanten").first
        hospitanten_group.assign_user self
      end
    end
  end
  private :add_to_group_if_requested


  # Corporations
  # ------------------------------------------------------------------------------------------

  # This returns all corporations of the user. The Corporation model inherits from the Group
  # model. corporations are child_groups of the corporations_parent_group in the DAG.
  #
  #   everyone
  #      |----- corporations_parent
  #      |                |---------- corporation_a      <----
  #      |                |                |--- ...           |--- These are corporations
  #      |                |---------- corporation_b      <----
  #      |                                 |--- ...
  #      |----- other_group_1
  #      |----- other_group_2
  #
  # Warning!
  # This method does not distinguish between regular members and guest members.
  # If a user is only guest in a corporation, `user.corporations` WILL list this corporation.
  #
  def corporations
    my_corporations = ( self.groups & Group.corporations ) if Group.corporations_parent
    my_corporations ||= []
    my_corporations.collect { |group| group.becomes( Corporation ) }
  end

  # This returns the corporations the user is currently member of.
  #
  def current_corporations
    self.corporations.select do |corporation|
      Role.of(self).in(corporation).current_member?
    end || []
  end
  
  # This returns the same as `current_corporations`, but sorted by the
  # date of joining the corporations, earliest joining first.
  #
  def sorted_current_corporations
    current_corporations.sort_by do |corporation|
      corporation.membership_of(self).valid_from || Time.zone.now
    end
  end
    
  # This returns the first corporation where the user is still member of or nil
  #
  def first_corporation
    # if self.corporations
    #   self.corporations.select do |corporation|
    #     not ( self.guest_of?( corporation )) and
    #     not ( self.former_member_of_corporation?( corporation ))
    #   end.sort_by do |corporation|
    #     corporation.membership_of( self ).valid_from or Time.zone.now
    #   end.first
    # end
    
    sorted_current_corporations.first
  end
  
  # This returns the groups within the first corporation
  # where the user is still member of in the order of entering the group.
  # The groups must not be special and the user most not be a special member.
  def my_groups_in_first_corporation
    if first_corporation
      my_memberships = UserGroupMembership.find_all_by_user( self )
      my_memberships = my_memberships.now.reorder{ |membership| membership.valid_from }
      my_groups = my_memberships.collect { |membership| membership.try( :group ) } if my_memberships
      my_groups ||= []
      my_groups.select do |group|
        first_corporation.in?( group.ancestor_groups )
      end.reject { |group| group.is_special_group? or self.guest_of?( group ) }
    else
      []
    end
  end

  def cached_last_group_in_first_corporation
    Rails.cache.fetch( [self, "last_group_in_first_corporation"] ) do
      my_groups_in_first_corporation.last
    end
  end


  # Corporate Vita
  # ==========================================================================================

  def corporate_vita_memberships_in(corporation)
    
    # StatusGroupMembership
    #   .now_and_in_the_past
    #   .find_all_by_user_and_corporation( self, corporation )
    
    groups = corporation.leaf_groups & self.parent_groups
    group_ids = groups.collect { |group| group.id }
    
    UserGroupMembership.now_and_in_the_past.find_all_by_user(self).where( ancestor_id: group_ids, ancestor_type: 'Group' )
  end


  # Status Groups
  # ------------------------------------------------------------------------------------------

  # This returns all status groups of the user, i.e. groups that represent the member
  # status of the user in a corporation.
  #
  # options:
  #   :with_invalid  =>  true, false
  #
  def status_groups(options = {})
    StatusGroup.find_all_by_user(self, options)
  end

  def status_group_memberships
    self.status_groups.collect do |group|
      StatusGroupMembership.find_by_user_and_group( self, group )
    end
  end

  def current_status_membership_in( corporation )
    if status_group = current_status_group_in(corporation)
      StatusGroupMembership.find_by_user_and_group(self, status_group)
    end
  end
  
  def current_status_group_in( corporation )
    StatusGroup.find_by_user_and_corporation(self, corporation)
  end


  # Relationships
  # ------------------------------------------------------------------------------------------

  # This returns all relationship opjects.
  #
  def relationships
    relationships_as_first_user + relationships_as_second_user
  end


  # Workflows
  # ------------------------------------------------------------------------------------------

  # This method returns all workflows applicable for this user, i.e. this returns
  # all workflows of all groups the user is a member of.
  #
  def workflows
    my_workflows = []
    self.groups.each do |group|
      my_workflows += group.child_workflows
    end
    return my_workflows
  end

  def workflows_for(group)
    (([group] + group.descendant_groups) & self.groups)
      .collect { |g| g.child_workflows }.select { |w| not w.nil? }.flatten
  end

  def workflows_by_corporation
    hash = {}
    other_workflows = self.workflows
    self.corporations.each do |corporation|
      corporation_workflows = self.workflows_for(corporation)
      hash.merge!( corporation.title.to_s => corporation_workflows )
      other_workflows -= corporation_workflows
    end
    hash.merge!( I18n.t(:others).to_s => other_workflows ) if other_workflows.count > 0
    return hash
  end

  # Events
  # ------------------------------------------------------------------------------------------

  # This method lists all upcoming events of the groups the user is member of.
  #
  def upcoming_events
    Event.upcoming.find_all_by_groups( self.groups ).direct
  end


  # Bookmarked Objects
  # ------------------------------------------------------------------------------------------

  # This method lists all bookmarked objets of this user.
  #
  def bookmarked_objects
    self.bookmarks.collect { |bookmark| bookmark.bookmarkable }
  end


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
        self.ancestor_groups.include? object.try(:becomes, Group)
      else  # only current memberships:
        self.groups.include? object.try(:becomes, Group)  # This uses the validity range mechanism
      end
    else
      self.ancestors.include? object
    end
  end

  # Admins
  # ------------------------------------------------------------------------------------------

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

  # Admin for this user
  # =====================================================================================
  #
  # Admin for this user are all user admins of any group of this user
  def user_admins
    result = []
    groups.collect do |group|
      result |= group.cached_user_admins
    end
    result
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
  
  # Hidden
  # ==========================================================================================
  #
  # Some users are hidden for regular users. They can only be seen by their administrators.
  # This is necessary for some organizations due to privacy reasons.
  #

  def hidden?
    self.hidden
  end

  def hidden
    self.member_of? Group.hidden_users
  end

  def hidden=(hidden)
    Group.hidden_users.assign_user self if hidden == true || hidden == "true"
    Group.hidden_users.unassign_user self if hidden == false || hidden == "false"
  end

  # Former Member
  # ==========================================================================================

  def former_member_of_corporation?( corporation )
    self.member_of? corporation.child_groups.find_by_flag(:former_members_parent)
  end
  

  # Group Flags
  # ==========================================================================================
  
  # This efficiently returns all flags of the groups the user is currently in.
  #
  # For example, ony can find out with one sql query whether a user is hidden:
  # 
  #     user.group_flags.include? 'hidden_users'
  # 
  def group_flags
    groups.joins(:flags).select('flags.key as flag').collect { |g| g.flag }
  end
  
  # Finder Methods
  # ==========================================================================================

  # This method returns the first user matching the given title.
  #
  def self.find_by_title( title )
    self.where("? LIKE CONCAT('%', first_name, ' ', last_name, '%')", title).select do |user|
      user.title == title
    end.first
  end
  
  def self.find_by_name( name )
    self.find_all_by_name(name).limit(1).first
  end    

  # This method finds all users having the given name attribute.
  # notice: case insensitive
  #
  def self.find_all_by_name( name ) # TODO: Test this
    self.where("CONCAT(first_name, ' ', last_name) = ?", name)
  end

  # This method finds all users having the given email attribute.
  # notice: case insensitive
  #
  def self.find_all_by_email( email ) # TODO: Test this; # TODO: optimize using where
    email_fields = ProfileField.where( type: "ProfileFieldTypes::Email", value: email )
    matching_users = email_fields
      .select{ |ef| ef.profileable_type == "User" }
      .collect { |ef| ef.profileable }
    return matching_users.to_a
  end
  
  def self.find_by_email( email )
    self.find_all_by_email(email).first
  end
  
  def self.with_group_flags
    self.joins(:groups => :flags)
  end
  
  def self.with_group_flag(flag)
    self.with_group_flags.where("flags.key = ?", flag)
  end
  
  def self.hidden
    self.with_group_flag('hidden_users')
  end
  
  def self.deceased
    self.joins(:profile_fields).where(:profile_fields => {label: 'date_of_death'})
  end
  
  def self.deceased_ids
    self.deceased.select('users.id').collect { |user| user.id }
  end
  
  def self.alive
    if self.deceased_ids.count > 0
      self.where('NOT users.id IN (?)', self.deceased_ids)
    else
      self.where(true)
    end
  end
  
  def self.without_account
    self.includes(:account).where(:user_accounts => { :user_id => nil })
  end
  
  def self.with_email
    self.joins(:profile_fields).where('profile_fields.type = ? AND profile_fields.value != ?', 'ProfileFieldTypes::Email', '')
  end
  
  def self.applicable_for_new_account
    self.without_account.alive.with_email
  end


  # Helpers
  # ==========================================================================================

  # The string returned by this method represents the user in the rails console.
  # For example, if you type `User.all` in the console, the answer would be:
  #
  #    User: alias_of_the_first_user, User: alias_of_the_second_user, ...
  #
  def inspect
    "User: " + self.alias
  end
  
end

