# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account, :female, :add_to_group

  attr_accessor             :create_account, :name, :add_to_group
                            # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :first_name, :last_name
  validates_uniqueness_of   :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of       :email, :with => /^[a-z0-9_.-]+@[a-z0-9-]+\.[a-z.]+$/i, :if => Proc.new { |user| user.email }

  has_profile_fields

  has_one                   :account, class_name: "UserAccount", autosave: true, inverse_of: :user, dependent: :destroy
  validates_associated      :account

  is_structureable          ancestor_class_names: %w(Page Group), descendant_class_names: %w(Page)

  has_dag_links             link_class_name: 'RelationshipDagLink', ancestor_class_names: %w(Relationship), descendant_class_names: %w(Relationship), prefix: 'relationships'

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name, :write_alias_attribute
  before_save               :build_account_if_requested, :add_to_group_if_requested

  def name
    first_name + " " + last_name
  end
  def name=( name )
    name_components = name.split( " " )
    if name_components.count > 1
      self.first_name = name_components[ 0..-2 ].join( " " )
      self.last_name = name_components[ -1 ]
    end
  end

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden 
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  def title
    name
  end

  def self.find_by_title( title )
    User.all.select { |user| user.title == title }.first
  end

  def self.by_title( title )
    User.find_by_title title
  end

  def alias
    @alias = UserAlias.new( read_attribute( :alias ), :user => self ) unless @alias.kind_of? UserAlias
    return @alias
  end
  def alias=( a )
    @alias = a
    write_alias_attribute
  end

  def capitalize_name
    self.first_name.capitalize! unless first_name.include?( " " ) # zwei Vornamen
    self.last_name.capitalize! unless last_name.include?( " " ) # "de Silva"
    self.name
  end

  def has_account?
    return true if self.account
  end
  
  def deactivate_account
    self.account.destroy if self.account
    self.account = nil
  end

  def relationships
    relationships_parent_relationships + relationships_child_relationships
  end

  # Versucht, einen Benutzer anhand eines login_strings zu identifizieren, der beim Anmelden eingegeben wird.
  # Das kann eine E-Mail-Adresse, ein Benutzername, Vor- und Zuname, etc. sein.
  def self.identify( login_string )
    UserIdentification.find_users login_string
  end

  def self.authenticate( login_string, password )
    UserAccount.authenticate login_string, password 
  end

  def groups
    self.ancestor_groups
  end

  def workflows
    my_workflows = []
    self.groups.each do |group|
      my_workflows += group.child_workflows
    end
    return my_workflows
  end

  # Verbindungen (im Sinne des Wingolfs am Hochschulort), d.h. Bänder, die ein Mitglied trägt.
  def corporations
    my_corporations = []
    if Group.corporations_parent
      my_corporations += ( self.ancestor_groups & Group.corporations ).select do |wah|
        ( wah.becomes( Wah ).aktivitas.descendant_users | wah.becomes( Wah ).philisterschaft.descendant_users ).include? self
      end.collect { |group| group.becomes( Wah ) }
    end
    return my_corporations
  end

  # Returns all UserGroupMemberships for this user. 
  # If the option :with_deleted is set true, this includes all deleted UserGroupMemberships.
  def memberships
    UserGroupMembership.find_all_by_user self
  end
  
  def inspect
    "User: " + self.alias
  end

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

  private

  def write_alias_attribute
    write_attribute :alias, @alias
  end

  def generate_alias_if_necessary
    self.alias.generate! if self.alias.blank?
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

    if self.create_account
      self.account.destroy if self.has_account?
      self.account = self.build_account
      self.create_account = false # to make sure that this code is nut run twice.
      return self.account
    end

  end

  def add_to_group_if_requested
    if self.add_to_group 
      group = add_to_group if add_to_group.kind_of? Group
      group = Group.find( add_to_group ) if add_to_group.to_i
      UserGroupMembership.create( user: self, group: group ) if group
    end
  end

end

