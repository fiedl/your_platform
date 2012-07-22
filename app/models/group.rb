# -*- coding: utf-8 -*-
class Group < ActiveRecord::Base
  attr_accessible :name, :token, :extensive_name, :internal_token, :direct_member_titles_string

#  has_dag_links   link_class_name: 'DagLink', ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group User Page)
  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group User Page Workflow)

  is_navable
  has_profile_fields

  after_create    :import_default_group_structure

  def title
    self.name
  end

  def self.first
    self.all.first.becomes self
  end

  def self.last
    self.all.last.becomes self
  end

  def self.by_token( token )
    ( self.all.select { |group| group.token == token } ).first.becomes self
  end

  def self.jeder
    g = Group.find_by_name( "Jeder" )
    if g
      if g.root_for_groups?
        return g
      else
        return g.ancestor_groups.first
      end
    end
  end

  def child_workflows
    Workflow
      .joins( :links_as_child )
      .where( :dag_links => { :ancestor_type => "Group", :ancestor_id => self.id, direct: true } )
      .uniq
  end

  def descendant_groups_by_name( descendant_group_name )
    self.descendant_groups.where( :name => descendant_group_name )
  end

  def descendant_users
    if self == Group.jeder
      return User.all
    else
      return super 
    end
  end

  def child_users
    if self == Group.jeder
      return descendant_users
    else
      return super
    end
  end

  def officers_group
    self.child_groups.find_by_name( "Amtsträger" ) unless self.name == "Amtsträger"
  end

  def officers
    officers = self.descendant_groups.find_all_by_name( "Amtsträger" ).collect{ |officer_group| officer_group.child_groups }.flatten
    return officers if officers.count > 0
  end

  def amtsträger
    officers
  end

  def self.jeder!
    unless self.jeder
      p "Creating group 'Jeder' ..."
      Group.create( name: "Jeder" )
    end
    return self.jeder
  end

  def self.wingolf_am_hochschulort
    ( self.jeder.child_groups.select { |group| group.name == "Wingolf am Hochschulort" } ).first if self.jeder
  end

  def self.wingolf_am_hochschulort!
    unless self.wingolf_am_hochschulort
      p "Creating group 'Wingolf am Hochschulort' ..."
      wah_group = Group.create( name: "Wingolf am Hochschulort" ) 
      raise 'There is no root group for all users (Group.jeder).' + 
        'But it is needed in order to create the group "Wingolf am hochschulort".' unless Group.jeder
      wah_group.parent_groups << Group.jeder
    end
    return self.wingolf_am_hochschulort
  end

  def self.bvs
    ( self.jeder.child_groups.select { |group| group.name == "Bezirksverbände" } ).first if self.jeder
  end

  def self.bvs!
    unless self.bvs
      p "Creating group 'Bezirksverbände' ..."
      bvs_group = Group.create( name: "Bezirksverbände" )
      raise "no group 'Jeder'" unless Group.jeder
      bvs_group.parent_groups << Group.jeder
    end
  end

  def import_default_group_structure( yaml_file_title = nil )
    yaml_file_title = self.name + ".yml" unless yaml_file_title
    yaml_file_name = File.join( Rails.root, "import", "default_group_sub_structures", yaml_file_title )
    if File.exists? yaml_file_name
      sub_group_hashes = []
      File.open( yaml_file_name, "r" ) do |file|
        sub_group_hashes = YAML::load(file)
      end
      sub_group_hashes = convert_group_names_to_group_hashes( sub_group_hashes ) # für verkürzte YAML-Schreibweise
      Group.hash_array_import_groups_into_parent_group( sub_group_hashes, self )
    end
  end

  def convert_group_names_to_group_hashes( group_names )
    group_names.map do |name|
      if name.kind_of? String
        { name: name }
      elsif name.kind_of? Hash
        unless name[ :name ]
          { name: name.keys.first, children: convert_group_names_to_group_hashes( name[ name.keys.first ] ) }
        end
      end
    end
  end

  def direct_member_titles_string
    child_users.collect { |user| user.title }.join( ", " )
  end
  def direct_member_titles_string=( titles_string )
    new_members_titles = titles_string.split( "," )
    new_members = new_members_titles.collect do |title|
      u = User.find_by_title( title.strip )
      self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
#      raise 'validation error: user not found: #{title}'
      u
    end
    for member in child_users
      unassign_user member unless member.in? new_members if member
    end
    for new_member in new_members
      assign_user new_member if new_member
    end
  end

  def assign_user( user )
    if user
      unless user.in? self.child_users
        self.child_users << user if user
      end
    end
  end

  def unassign_user( user )
    link = DagLink.find_edge( self.becomes( Group ), user )
    link.destroy if link.destroyable? if link
  end

  # Importiere Gruppen aus CSV-Datei
  def self.csv_import_groups_into_parent_group( csv_file_title, parent_group )
    import_file_name = File.join( Rails.root, "import", csv_file_title )
    require 'csv'
    CSV.foreach import_file_name, headers: true, col_sep: ';' do |row|
      new_child_group = Group.create row.to_hash
      parent_group.child_groups << new_child_group
    end
  end

  # Importiert ein JSON-Array von Gruppen in die Grupe +parent_group+. 
  # Kann z.B. zum Import der Wingolf-am-Hochschulort-Gruppen verwendet werden.
  def self.json_import_groups_into_parent_group( json_file_title, parent_group )
    raise "no parent group given during import" unless parent_group
    import_json_file = File.open( File.join( Rails.root, "import", json_file_title ), "r" )
    json = IO.read( import_json_file )
    new_child_groups_hash_array = JSON.parse( json )
    p self.hash_array_import_groups_into_parent_group new_child_groups_hash_array, parent_group
  end

  def self.hash_array_import_groups_into_parent_group( hash_array_of_groups, parent_group )
    return unless hash_array_of_groups
    counter_for_created_groups = 0
    for new_group_hash in hash_array_of_groups do
      unless parent_group.children.select { |child| child.name == new_group_hash[ "name" ] }.count > 0
        sub_group_hash_array = new_group_hash[ "children" ] 
        sub_group_hash_array = new_group_hash[ :children ] unless sub_group_hash_array
        new_group_hash.reject! { |key| not Group.attr_accessible[:default].include? key }
        g = Group.create( new_group_hash )
        g.parent_groups << parent_group
        g.save
        self.hash_array_import_groups_into_parent_group sub_group_hash_array, g if sub_group_hash_array
        counter_for_created_groups += 1
      end
    end
    return counter_for_created_groups.to_s + " groups created."
  end

  # Entferne alle DagLinks im Baum unter dieser Gruppe.
  def destroy_links_to_descendants
    descendant_groups = self.descendant_groups
    descendant_groups_and_self = descendant_groups + [ self ]
    for group in descendant_groups_and_self do
      for link in group.links_as_parent do
        if link.destroyable?
          link.destroy 
        else
          p "KANN LINK NICHT ZERSTÖREN:".bold.red
          p link 
        end
      end
    end
  end

  def memberships
    UserGroupMembership.find_all_by_group self 
  end

  def membership_of( user )
    UserGroupMembership.find_by_user_and_group( user, self )
  end
end

class Groups 
  
  def self.all
    Group.all
  end

  def self.of_user( user )
    user.groups
  end

end
