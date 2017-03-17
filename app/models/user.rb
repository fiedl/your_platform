class User < ActiveRecord::Base
  if defined? attr_accessible
    attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account, :female, :add_to_group,
                              :add_to_corporation, :date_of_birth, :localized_date_of_birth,
                              :aktivmeldungsdatum, :study_address, :home_address, :work_address, :phone, :mobile,
                              :notification_policy
  end

  # Gamification: https://github.com/merit-gem/merit
  include Merit
  has_merit

  attr_accessor             :create_account, :add_to_group, :add_to_corporation
  # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :last_name
  validates_format_of       :first_name, with: /\A[^\,]*\z/, if: Proc.new { |user| user.first_name.present? }  # The name must not contain a comma.
  validates_format_of       :last_name, with: /\A[^\,]*\z/

  before_validation         :change_alias_if_already_taken
  validates_uniqueness_of   :alias, :if => Proc.new { |user| user.account and user.alias.present? }
  validates_format_of       :email, :with => Devise::email_regexp, :if => Proc.new { |user| user.email.present? }, judge: :ignore

  has_one                   :account, class_name: "UserAccount", autosave: true, inverse_of: :user, dependent: :destroy
  validates_associated      :account

  delegate                  :send_welcome_email, :to => :account

  is_structureable          ancestor_class_names: %w(Page Group Event), descendant_class_names: %w(Page)

  has_many                  :relationships_as_first_user, foreign_key: 'user1_id', class_name: "Relationship", dependent: :destroy, inverse_of: :user1

  has_many                  :relationships_as_second_user, foreign_key: 'user2_id', class_name: "Relationship", dependent: :destroy, inverse_of: :user2

  has_many                  :bookmarks
  has_many                  :last_seen_activities

  has_many                  :comments, foreign_key: 'author_user_id', class_name: 'Comment'
  has_many                  :mentions, foreign_key: 'whom_user_id', class_name: 'Mention'

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name
  before_save               :build_account_if_requested
  after_save                :add_to_group_if_requested


  # Easy user settings: https://github.com/huacnlee/rails-settings-cached
  # For example:
  #
  #     user = User.find(123)
  #     user.settings.color = :red
  #     user.settings.color  # =>  :red
  #
  include RailsSettings::Extend


  # Mixins
  # ==========================================================================================

  include UserMixins::Memberships
  include UserMixins::Identification
  include ProfileableMixins::Address
  include UserCorporations
  include UserGroups
  include UserProfile
  include UserDateOfBirth
  include UserAvatar
  include UserRoles
  include UserNotifications
  include UserPosts
  include UserMerit
  include UserRecommendations
  include UserOmniauth
  include UserSearch
  include UserContacts
  include UserVcfExport
  include UserDocuments
  include UserGeoSearch
  include UserLocation

  # General Properties
  # ==========================================================================================

  # The name of the user, i.e. first_name and last_name.
  #
  def name
    first_name + " " + last_name if first_name && last_name
  end
  def name=(new_name)
    if new_name.present?
      self.last_name = new_name.strip.split(" ").last
      self.first_name = new_name.gsub(last_name, "").strip
    else
      self.last_name = nil
      self.first_name = nil
    end
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
    return name_string if name_string.try(:include?, " ")
    return name_string.slice(0, 1).capitalize + name_string.slice(1..-1) if name_string.present?
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


  # The preferred locale of the user, which can be set through
  # the user settings or the page footer.
  #
  # In order to suppress the default value and just to read the
  # setting from the database, call `user.locale(true)`.
  #
  def locale(no_default = false)
    if no_default
      super()
    else
      super() || Setting.preferred_locale || I18n.default_locale
    end
  end

  def timezone
    # TODO: Implement a setting where the user can choose his own time zone.
    # See: http://railscasts.com/episodes/106-time-zones-revised
    User.default_timezone
  end
  def time_zone
    timezone
  end

  def self.default_timezone
    AppVersion.default_timezone
  end
  def self.default_time_zone
    default_timezone
  end


  def ability
    @ability ||= Ability.new(self)
  end
  def can?(what, with_whom)
    ability.can? what, with_whom
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

  # This is the salutation for addess labels, for example:
  #
  #     Mr.
  #     John Doe
  #
  def male_or_female_salutation
    if female?
      if age < 18
        I18n.translate(:to_ms, locale)
      else
        I18n.translate(:to_mrs, locale)
      end
    else
      I18n.translate(:to_mr, locale)
    end
  end


  # Date of Death
  # The date of death is localized already!
  # Why?
  #
  def date_of_death
    profile_fields.where(label: 'date_of_death').first.try(:value)
  end

  def set_date_of_death_if_unset(new_date_of_death)
    new_date_of_death = I18n.localize(new_date_of_death.to_date)
    unless self.date_of_death
      profile_fields.create(type: "ProfileFields::General", label: 'date_of_death', value: new_date_of_death)
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
      Membership.find_by_user_and_group(self, group).invalidate at: date
    end
  end

  def postal_address_with_name_surrounding
    address_label.to_s
  end

  def name_with_surrounding
    (
      name_surrounding_profile_field.try(:text_above_name).to_s + "\n" +
      "#{name_surrounding_profile_field.try(:name_prefix)} #{name} #{name_surrounding_profile_field.try(:name_suffix)}".strip + "\n" +
      name_surrounding_profile_field.try(:text_below_name).to_s
    ).strip
  end

  def address_label
    AddressLabel.new(self.name, self.postal_address_field_or_first_address_field,
      self.name_surrounding_profile_field, self.personal_title, self.corporation_name)
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
    self.generate_alias! if self.account and self.alias.blank?
  end
  private :generate_alias_if_necessary

  def change_alias_if_already_taken
    if self.has_account? && self.alias.present? && User.where(alias: self.alias).count > 1
      self.generate_alias!
    end
  end



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
  def guest_user?
    has_no_account?
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
      create_account = false # to make sure that this code is nut run twice.
      return self.account
    end

  end
  private :build_account_if_requested

  def token
    account.try(:auth_token)
  end


  # Activities
  # ------------------------------------------------------------------------------------------

  def find_or_build_last_seen_activity
    last_seen_activities.last || last_seen_activities.build
  end

  def update_last_seen_activity(description = nil, object = nil)
    unless readonly?
      if description and not self.incognito?
        activity = find_or_build_last_seen_activity
        activity.touch unless activity.new_record? # even if the attributes didn't change. The user probably hit 'reload' then.
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
      Membership.create( user: self, group: group ) if group
      self.add_to_group = nil
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
      self.add_to_corporation = nil
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
  def corporations(options = {})
    return corporations_with_past if options[:with_invalid]
    groups.where(type: 'Corporation')
  end

  def corporations_with_past
    ancestor_groups.where(type: 'Corporation')
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
      corporation.membership_of(self).valid_from || Time.zone.now - 100.years
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

  # The primary corporation is the one the user is most associated with.
  #
  #     user.primary_corporation
  #     user.primary_corporation at: 2.years.ago
  #
  def primary_corporation(options = {})
    if options[:at]
      memberships.with_past.where(ancestor_id: Group.flagged(:full_members).pluck(:id))
        .at_time(options[:at]).order(:valid_from)
        .first.try(:group).try(:corporation)
    else
      # Temporary hack. This might not be correct for all cases.
      first_corporation
    end
  end

  # This returns the groups within the first corporation
  # where the user is still member of in the order of entering the group.
  # The groups must not be special and the user most not be a special member.
  def my_groups_in_first_corporation
    if first_corporation
      self.groups.select do |group|
        group.ancestor_groups.include?(self.first_corporation) and
        not group.is_special_group? and
        not self.guest_of?(group)
      end
    else
      Group.none
    end
  end

  def last_group_in_first_corporation
    my_groups_in_first_corporation.last
  end


  # Corporate Vita
  # ==========================================================================================

  def corporate_vita_memberships_in(corporation)
    group_ids = corporation.status_groups.map(&:id) & self.parent_group_ids
    self.memberships.with_past.where(ancestor_id: group_ids, ancestor_type: 'Group').order(valid_from: :asc)
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
    if options[:with_invalid]
      self.parent_groups.where(type: "StatusGroup")
    else
      self.direct_groups.where(type: "StatusGroup")
    end
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
    current_status_group_in(first_corporation || corporations.first)
  end

  def status_export_string
    self.corporations.collect do |corporation|
      if membership = self.current_status_membership_in(corporation)
        "#{I18n.localize(membership.valid_from.to_date) if membership.valid_from}: #{membership.group.name.try(:singularize)} in #{corporation.name}"
      else
        ""
      end
    end.join("\n")
  end
  def status_string
    status_export_string
  end

  def status
    status_string
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

  # This method lists all upcoming events of the groups the user is member of
  # as well as all events the user has joined.
  #
  def events
    Event.find_all_by_user(self)
  end
  def upcoming_events
    events.upcoming
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
    # avoid double negation (i.e. select pages where user is member!)
    group_ids_the_user_is_no_member_of =
      Group.pluck(:id) - self.group_ids
    pages_that_belong_to_groups_the_user_is_no_member_of = Page
      .includes(:ancestor_groups)
      .where(groups: {id: group_ids_the_user_is_no_member_of})
    Page
      .where.not(id: (pages_that_belong_to_groups_the_user_is_no_member_of + [0])) # +[0]-hack: otherwise the list is empty when all pages should be shown, i.e. for fresh systems.
      .for_display
      .order('pages.updated_at DESC')
  end


  # Bookmarked Objects
  # ------------------------------------------------------------------------------------------

  # This method lists all bookmarked objets of this user.
  #
  def bookmarked_objects
    self.bookmarks.collect { |bookmark| bookmark.bookmarkable }
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

  def self.find_all_hidden
    self.where(id: Group.hidden_users.member_ids)
  end

  def self.find_all_non_hidden
    self.where.not(id: Group.hidden_users.member_ids)
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

  # This finds a user matching an auth token.
  #
  def self.find_by_token(token)
    UserAccount.where(auth_token: token).limit(1).first.try(:user)
  end

  # This method finds all users having the given email attribute.
  # notice: case insensitive
  #
  def self.find_all_by_email( email ) # TODO: Test this; # TODO: optimize using where
    email_fields = ProfileField.where( type: "ProfileFields::Email", value: email )
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
      self.all
    end
  end

  def self.without_account
    self.includes(:account).where(:user_accounts => { :user_id => nil })
  end

  def self.with_email
    self.joins(:profile_fields).where('profile_fields.type = ? AND profile_fields.value != ?', 'ProfileFields::Email', '')
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

  def self.apply_filter(filter)
    if filter && filter.include?("without_email")
      self.without_email
    else
      self.all
    end
  end

  def self.without_email
    ids = self.select { |user| not user.email.present? or user.email_needs_review? }.map(&:id)
    where(id: ids)
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

  # ==========================================================================================


  def parent
    status_group_in_primary_corporation || direct_groups.first
  end

  include UserCaching if use_caching?
end
