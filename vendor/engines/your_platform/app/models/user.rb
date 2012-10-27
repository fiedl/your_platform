# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account, :female, :add_to_group

  attr_accessor             :create_account, :add_to_group
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


  # General Properties
  # ==========================================================================================

  # The name of the user, i.e. first_name and last_name.
  #
  def name
    first_name + " " + last_name
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
    self.first_name.capitalize! unless first_name.include?( " " ) # zwei Vornamen
    self.last_name.capitalize! unless last_name.include?( " " ) # "de Silva"
    self.name
  end

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



  # Associated Objects
  # ==========================================================================================

  # Alias
  # ------------------------------------------------------------------------------------------

  # The UserAlias class inherits from String, but has some more methods, e.g. a method
  # to generate a new alias from other user attributes. To make sure that `alias` returns
  # an object of UserAlias type, the accessor methods are overridden here.
  #
  def alias
    @alias = UserAlias.new( read_attribute( :alias ), :user => self ) unless @alias.kind_of? UserAlias
    return @alias
  end
  def alias=( a )
    @alias = a
    write_alias_attribute
  end

  def write_alias_attribute
    write_attribute :alias, @alias
  end
  private :write_alias_attribute

  def generate_alias_if_necessary
    self.alias.generate! if self.alias.blank?
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

  # This method activates the user account, i.e. grants the user the right to log in.
  # 
  def activate_account
    unless self.account
      self.account = self.build_account
      self.save
    end
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

  # This returns all groups the user is currently a member of. In terms of the DAG model,
  # this method returns all ancestor groups.
  #
  def groups
    self.ancestor_groups
  end

  def add_to_group_if_requested
    if self.add_to_group 
      group = add_to_group if add_to_group.kind_of? Group
      group = Group.find( add_to_group ) if add_to_group.to_i unless group
      UserGroupMembership.create( user: self, group: group ) if group
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
    my_corporations = ( self.ancestor_groups & Group.corporations ) if Group.corporations_parent
    my_corporations = my_corporations.collect { |group| group.becomes( Corporation ) }
    return my_corporations
  end


  # Memberships
  # ------------------------------------------------------------------------------------------

  # Returns all UserGroupMemberships for this user. 
  # Since this is an ActiveRelation object, one can chain other conditions, like:
  # 
  #     some_user.memberships.with_deleted
  #     some_user.memberships.in_the_past
  #
  def memberships
    UserGroupMembership.find_all_by_user self
  end

  
  # Relationships
  # ------------------------------------------------------------------------------------------
  
  # This returns all relationship opjects.
  #
  def relationships
    # At the moment, the partners of a relationships are stored in a DAG model
    # prexied with 'relationships_'. 
    relationships_parent_relationships + relationships_child_relationships
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


  # User Identification and Authentification
  # ==========================================================================================

  include UserMixins::Identification
  
  # This method tries to authenticate a user by a login_string and a password.
  # The user is identified by the login_string (see `self.identify`).
  #
  # If the given password matches the identified user, the hereby authenticated user
  # is returned. Otherwise, this method returns `nil`.
  #
  def self.authenticate( login_string, password )
    UserAccount.authenticate login_string, password 
  end


  # Roles and Rights
  # ==========================================================================================

  # This method finds all objects the user is an administrator of.
  def admin_of
    self.administrated_objects
  end

  # This method verifies if the user is administrator of the given structureable object.
  def admin_of?( structureable )
    self.admin_of.include? structureable
  end

  # This method returns all structureable objects the user is directly administrator of,
  # i.e. the user is a member of the administrators group of this object.
  def directly_administrated_objects
    admin_groups = self.ancestor_groups.find_all_by_flag( :admins_parent )
    directly_administrated_objects = admin_groups.collect do |admin_group|
      admin_group_parent = admin_group.parents.first 
      if admin_group_parent.has_flag? :officers_parent
        administrated_object = admin_group_parent.parents.first
      else
        administrated_object = admin_group_parent
      end
      administrated_object
    end
  end

  # This method returns all structureable objects the user is administrator of.
  def administrated_objects
    administrated_objects = directly_administrated_objects
    administrated_objects += directly_administrated_objects.collect do |directly_administrated_object|
      directly_administrated_object.descendants
    end.flatten
    administrated_objects
  end
  

  # Finder Methods
  # ==========================================================================================

  # This method returns the first user matching the given title.
  #
  def self.find_by_title( title )
    User.all.select { |user| user.title == title }.first
  end
  
  # This method finds all users having the given name attribute.
  # notice: case insensitive
  #
  def self.find_all_by_name( name ) # TODO: Test this; # TODO: optimize using where
    User.all.select { |user| user.name.downcase == name.downcase }
  end

  # This method finds all users having the given email attribute.
  # notice: case insensitive
  #
  def self.find_all_by_email( email ) # TODO: Test this; # TODO: optimize using where
    User.all.select { |user| user.email.downcase == email.downcase }
  end

  # Debug Helpers
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

