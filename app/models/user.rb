# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account, :female, :add_to_group,
                            :add_to_corporation, :date_of_birth, :localized_date_of_birth,
                            :aktivmeldungsdatum, :study_address, :home_address, :work_address, :phone, :mobile

  attr_accessor             :create_account, :add_to_group, :add_to_corporation
  # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :first_name, :last_name
  validates_format_of       :first_name, with: /^[^\,]*$/  # The name must not contain a comma.
  validates_format_of       :last_name, with: /^[^\,]*$/
  
  validates_uniqueness_of   :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of       :email, :with => Devise::email_regexp, :if => Proc.new { |user| user.email.present? }, judge: :ignore

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
  has_many                  :last_seen_activities

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name
  before_save               :build_account_if_requested
  after_save                :add_to_group_if_requested
  after_save                { self.delay.delete_cache }
  
  # after_commit     					:delete_cache, prepend: true
  # before_destroy    				:delete_cache, prepend: true
  

  # Mixins
  # ==========================================================================================
  
  include UserMixins::Memberships
  include UserMixins::Identification
  include ProfileableMixins::Address
  include UserCompany

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
  
  def name_affix
    title.gsub(name, '').strip
  end
  
  
  # This sets the format of the User urls to be
  # 
  #     example.com/users/24-john-doe
  #
  # rather than just
  #
  #     example.com/users/24
  #
  # This method uses a cache on purpose, since it is directly used by rails
  # to construct the url.
  #
  def to_param
    "#{id} #{title}".parameterize
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
  def male?
    not female?
  end

  # Date of Birth
  #
  def date_of_birth
    cached { date_of_birth_profile_field.value.to_date if date_of_birth_profile_field.value if date_of_birth_profile_field }
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
    cached do
      now = Time.now.utc.to_date
      dob = self.date_of_birth
      if dob
        now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      else
        nil
      end
    end
  end
  
  def birthday_this_year
    cached do
      begin
        date_of_birth.change(:year => Time.zone.now.year)
      rescue
        if date_of_birth.try(:month) == 2 && date_of_birth.try(:day) == 29
          date_of_birth.change(year: Time.zone.now.year, month: 3, day: 1)
        else
          nil
        end
      end
    end
  end
  
    
  # Date of Death
  # The date of death is localized already!
  # Why?
  #
  def date_of_death
    cached { profile_fields.where(label: 'date_of_death').first.try(:value) }
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
    account.try(:destroy)
  end
  
  # Defines whether the user can be marked as deceased (by a workflow).
  #
  def markable_as_deceased?
    alive?
  end
  
  def end_all_non_corporation_memberships(options = {})
    date = options[:at] || Time.zone.now
    for group in (self.direct_groups - Group.corporations_parent.descendant_groups)
      UserGroupMembership.find_by_user_and_group(self, group).invalidate at: date
    end
  end
  
  def postal_address_with_name_surrounding
    address_label.to_s
  end

  def address_label
    cached do
      AddressLabel.new(self.name, self.postal_address_field_or_first_address_field, 
        self.name_surrounding_profile_field, self.personal_title)
    end
  end
  
  # Phone Profile Fields
  # 
  def phone_profile_fields
    profile_fields.where(type: 'ProfileFieldTypes::Phone').select do |field|
      not field.label.downcase.include? 'fax'
    end
  end
  
  def landline_profile_fields
    phone_profile_fields - mobile_phone_profile_fields
  end
  def mobile_phone_profile_fields
    phone_profile_fields.select do |field|
      field.label.downcase.include?('mobil') or field.label.downcase.include?('handy')
    end
  end
  
  def phone
    (landline_profile_fields + phone_profile_fields).first.try(:value)
  end
  def phone=(new_number)
    (landline_profile_fields.first || profile_fields.create(label: I18n.t(:phone), type: 'ProfileFieldTypes::Phone')).update_attributes(value: new_number)
  end
  
  def mobile
    (mobile_phone_profile_fields + phone_profile_fields).first.try(:value)
  end
  def mobile=(new_number)
    (mobile_phone_profile_fields.first || profile_fields.create(label: I18n.t(:mobile), type: 'ProfileFieldTypes::Phone')).update_attributes(value: new_number)
  end
  
  
  # Other infos from profile fields
  # ------------------------------------------------------------------------------------------
  
  def profile_field_value(label)
    profile_fields.where(label: label).first.try(:value).try(:strip)
  end
  def personal_title
    cached { profile_field_value 'personal_title' }
  end
  
  def academic_degree
    cached { profile_field_value 'academic_degree' }
  end

  def name_surrounding_profile_field
    profile_fields.where(type: "ProfileFieldTypes::NameSurrounding").first
  end
  def text_above_name
    name_surrounding_profile_field.try(:text_above_name).try(:strip)
  end
  def text_below_name
    name_surrounding_profile_field.try(:text_below_name).try(:strip)
  end
  def text_before_name
    name_surrounding_profile_field.try(:name_prefix).try(:strip)
  end
  def text_after_name
    name_surrounding_profile_field.try(:name_suffix).try(:strip)
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


  # Activities
  # ------------------------------------------------------------------------------------------

  def find_or_build_last_seen_activity
    last_seen_activities.last || last_seen_activities.build
  end
  
  def update_last_seen_activity(description = nil, object = nil)
    unless readonly?
      if description and not self.incognito?
        activity = find_or_build_last_seen_activity
        activity.touch # even if the attributes didn't change. The user probably hit 'reload' then.
        activity.description = description
        activity.link_to_object = object
        activity.save
      else
        last_seen_activities.destroy_all
      end
    end
  end

  # Groups
  # ------------------------------------------------------------------------------------------

  def add_to_group_if_requested
    if self.add_to_group
      group = add_to_group if add_to_group.kind_of? Group
      group = Group.find( add_to_group ) if add_to_group.to_i unless group
      UserGroupMembership.create( user: self, group: group ) if group
    end
    if self.add_to_corporation.present?
      corporation = add_to_corporation if add_to_corporation.kind_of? Group
      corporation ||= Group.find(add_to_corporation) if add_to_corporation.kind_of? Fixnum
      corporation ||= Group.find(add_to_corporation.to_i) if add_to_corporation.kind_of?(String) && add_to_corporation.to_i.kind_of?(Fixnum)
      if corporation
        status_group = corporation.becomes(Corporation).status_groups.first || raise('no status group in this corporation!')
        status_group.assign_user self
      else
        raise 'corporation not found.'
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
    cached do
      my_corporation_ids = (self.group_ids & Group.corporations.pluck(:id) ) if Group.corporations_parent
      my_corporation_ids ||= []
      Corporation.find my_corporation_ids
    end
  end

  # This returns the corporations the user is currently member of.
  #
  def current_corporations
    cached do
      self.corporations.select do |corporation|
        Role.of(self).in(corporation).current_member?
      end || []
    end
  end

  # This returns the same as `current_corporations`, but sorted by the
  # date of joining the corporations, earliest joining first.
  #
  def sorted_current_corporations
    cached do
      current_corporations.sort_by do |corporation|
        corporation.membership_of(self).valid_from || corporation.membership_of(self).created_at
      end
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
    cached do
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
  end
  
  def last_group_in_first_corporation
    my_groups_in_first_corporation.last
  end


  # Corporate Vita
  # ==========================================================================================

  def corporate_vita_memberships_in(corporation)
    Rails.cache.fetch([self, 'corporate_vita_memberships_in', corporation], expires_in: 1.week) do
      group_ids = corporation.status_groups.map(&:id) & self.parent_groups.map(&:id)
      UserGroupMembership.now_and_in_the_past.find_all_by_user(self).where(ancestor_id: group_ids, ancestor_type: 'Group')
    end
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
  
  def current_status_group_in(corporation)
    StatusGroup.find_by_user_and_corporation(self, corporation) if corporation
  end
  
  def status_group_in_primary_corporation
    # - First try the `first_corporation`,  which does not consider corporations the user is
    #   a former member of.
    # - Next, use all corporations, which applies to completely excluded members.
    #
    cached { current_status_group_in(first_corporation || corporations.first) }
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
    (([group.becomes(Group)] + group.descendant_groups) & self.groups)
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
  
  # This makes the user join an event or a grop.
  #
  def join(event_or_group)
    if event_or_group.kind_of? Group
      event_or_group.assign_user self
    elsif event_or_group.kind_of? Event
      event_or_group.attendees_group.assign_user self
    end
  end
  def leave(event_or_group)
    if event_or_group.kind_of? Group
      # TODO: Change to `unassign` when he can have multiple dag links between two nodes.
      # event_or_group.members.destroy(self)  
      raise 'We need multiple dag links between two nodes!'
    elsif event_or_group.kind_of? Event
      # TODO: Change to `unassign` when he can have multiple dag links between two nodes.
      event_or_group.attendees_group.members.destroy(self)  
    end
  end
  
  
  # News Entries (Pages)
  # -------------------
  
  # List news (Pages) that concern the user.
  #
  #     everyone ---- page_1 ---- page_2      <--- show
  #         |
  #         |----- group_1 ---- page_3        <--- DO NOT show
  #         |
  #         |----- group_2 ---- user
  #         |        |-- page_4               <--- show
  #         |
  #         |--- user
  #     
  def news_pages
    # List all pages that do not have ancestor groups
    # which the user is no member of.
    #
    
    # THIS WORKS BUT LOOKS UGLY. TODO: Refactor this:
    group_ids_the_user_is_no_member_of = 
      Group.pluck(:id) - self.group_ids
    pages_that_belong_to_groups_the_user_is_no_member_of = Page
      .includes(:ancestor_groups)
      .where(groups: {id: group_ids_the_user_is_no_member_of})
    Page
      .where('NOT id IN (?)', (pages_that_belong_to_groups_the_user_is_no_member_of + [0])) # +[0]-hack: otherwise the list is empty when all pages should be shown, i.e. for fresh systems.
      .order('pages.updated_at DESC')
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
    cached { self.member_of? Group.hidden_users }
  end

  def hidden=(hidden)
    Group.hidden_users.assign_user self if hidden == true || hidden == "true"
    Group.hidden_users.unassign_user self if hidden == false || hidden == "false"
  end
  
  def self.find_all_hidden
    self.where(id: Group.hidden_users.member_ids)
  end
  
  def self.find_all_non_hidden
    non_hidden_user_ids = User.pluck(:id) - Group.hidden_users.member_ids
    self.where(id: non_hidden_user_ids)  # in order to make it work with cancan.
  end

  # Former Member
  # ==========================================================================================

  def former_member_of_corporation?( corporation )
    corporation.becomes(Corporation).former_members.include? self
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
    groups.joins(:flags).pluck('flags.key')
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
      Group.everyone.admins << self
    else
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.main_admins_parent).try(:destroy)
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.admins_parent).try(:destroy)
    end
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
    self.deceased.pluck(:id)
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
    self.alive.without_account.with_email
  end
  
  def self.joins_groups
    self.joins(:groups).where('dag_links.valid_to IS NULL')
  end
  
  def accept_terms(terms_stamp)
    self.accepted_terms = terms_stamp
    self.accepted_terms_at = Time.zone.now
    save!
  end
  def accepted_terms?(terms_stamp)
    self.accepted_terms == terms_stamp
  end
  
    # Helpers
  # ==========================================================================================

  # The string returned by this method represents the user in the rails console.
  # For example, if you type `User.all` in the console, the answer would be:
  #
  #    User: alias_of_the_first_user, User: alias_of_the_second_user, ...
  #
  def inspect
    "User: #{self.id} #{self.alias}"
  end
  
end

