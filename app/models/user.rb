# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :name, :alias, :email, :create_account

  attr_accessor             :create_account, :name
                            # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :first_name, :last_name
  validates_uniqueness_of   :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of       :email, :with => /^[a-z0-9_.-]+@[a-z0-9-]+\.[a-z.]+$/i, :if => Proc.new { |user| user.email }

  has_profile_fields

  has_one                   :account, class_name: "UserAccount", autosave: true, inverse_of: :user, dependent: :destroy

  is_structureable          ancestor_class_names: %w(Page Group), descendant_class_names: %w(Page)

  has_dag_links             link_class_name: 'RelationshipDagLink', ancestor_class_names: %w(Relationship), descendant_class_names: %w(Relationship), prefix: 'relationships'

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name, :write_alias_attribute
  before_save               :build_account_if_requested

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

  # Diese Funktion gibt eine sinnvolle Beschriftung des Benutzers zurück, z.B. für die Beschriftung von Menüpunkten, 
  # die diesen Benutzer repräsentieren. Damit ist der Aufruf der gleiche wie etwa beim Page-Modell. 
  # <tt>@title = page.title</tt>, <tt>@title = user.title</tt>.
  # Die Funktion gibt *nicht* den akademischen Titel oder die Anrede des Benutzers zurück.
  def title
    ( name + "  " + aktivitaetszahl ).strip
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
    if Group.wingolf_am_hochschulort
      my_corporations += ( self.ancestor_groups & Group.wingolf_am_hochschulort.child_groups ).select do |wah|
        ( wah.becomes( Wah ).aktivitas.descendant_users | wah.becomes( Wah ).philisterschaft.descendant_users ).include? self
      end
    end
    return my_corporations
  end

  # Der Bezirksverband, dem der Benutzer zugeordnet ist.
  def bv
    bv_of_this_user = ( Bv.all & self.ancestor_groups ).first
    return bv_of_this_user.becomes Bv if bv_of_this_user
  end

  def aktivitaetszahl
    self.corporations.collect do |corporation| 
      year_of_joining = ""
      year_of_joining = corporation.membership_of( self ).created_at.to_s[2, 2] if corporation.membership_of( self ).created_at
      corporation.token + "\u2009" + year_of_joining
    end.join( " " )
  end

  # Returns all UserGroupMemberships for this user. 
  # If the option :with_deleted is set true, this includes all deleted UserGroupMemberships.
  def memberships( options = {} )
    UserGroupMembership.find_all_by_user self, options
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

end

