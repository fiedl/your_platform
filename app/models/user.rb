# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible           :first_name, :last_name, :alias, :email, :create_account

  attr_accessor             :create_account
                            # Boolean, der vormerkt, ob dem (neuen) Benutzer ein Account hinzugefügt werden soll.

  validates_presence_of     :first_name, :last_name, :alias, :email
  validates_uniqueness_of   :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of       :email, :with => /^[a-z0-9_.-]+@[a-z0-9-]+\.[a-z.]+$/i, :if => Proc.new { |user| user.email }

  has_many                  :profile_fields, :autosave => true

  has_one                   :user_account, autosave: true

  has_dag_links             link_class_name: 'DagLink', ancestor_class_names: %w(Page Group), descendant_class_names: %w(Page)
  has_dag_links             link_class_name: 'RelationshipDagLink', ancestor_class_names: %w(Relationship), descendant_class_names: %w(Relationship), prefix: 'relationships'

  is_navable

  before_save               :generate_alias_if_necessary, :capitalize_name, :write_alias_attribute
  after_save                Proc.new { |user| user.profile.save }


  def name
    first_name + " " + last_name
  end

  # Diese Funktion gibt eine sinnvolle Beschriftung des Benutzers zurück, z.B. für die Beschriftung von Menüpunkten, 
  # die diesen Benutzer repräsentieren. Damit ist der Aufruf der gleiche wie etwa beim Page-Modell. 
  # <tt>@title = page.title</tt>, <tt>@title = user.title</tt>.
  # Die Funktion gibt *nicht* den akademischen Titel oder die Anrede des Benutzers zurück.
  def title
    name # TODO Später hier vmlt. die Aktivitätszahl hinzufügen.
  end

  def profile
    @profile = Profile.new( self ) unless @profile
    return @profile
  end

  def alias
    @alias = UserAlias.new( read_attribute( :alias ), :user => self ) unless @alias.kind_of? UserAlias
    return @alias
  end
  def alias=( a )
    @alias = a
    write_alias_attribute
  end

  def email
    profile.email
  end
  def email=( email )
    profile.email = email
  end

  def capitalize_name
    self.first_name.capitalize!
    self.last_name.capitalize! unless last_name.include?( " " ) # "de Silva"
    self.name
  end

  def user_account
    @account = super unless @account
    @account = build_user_account unless @account
    return @account
  end

  def account
    user_account
  end

  def has_account?
    # Wenn der Account keine ID hat, dann existiert er nicht.
    user_account.id.to_b
  end

  def deactivate_account
    user_account.destory
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

  private

  def write_alias_attribute
    write_attribute :alias, @alias
  end

  def generate_alias_if_necessary
    self.alias.generate! if self.alias.blank?
  end

end

