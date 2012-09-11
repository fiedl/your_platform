# -*- coding: utf-8 -*-
#
# This class represents a user group. Besides users, groups may have sub-groups as children.
# One group may have several parent-groups. Therefore, the relations between groups, users,
# etc. is stored using the DAG model, which is implemented by the `is_structureable` method.
# 
class Group < ActiveRecord::Base
  attr_accessible( :name, # just the name of the group; example: 'Corporation A'
                   :token, # (optional) a short-name, abbreviation of the group's name, in 
                           # a global context; example: 'A'
                   :internal_token, # (optional) an internal abbreviation, i.e. used by the 
                                    # members of the group; example: 'AC'
                   :extensive_name, # (optional) a long version of the group's name;
                                    # example: 'The Corporation of A'
                   :direct_member_titles_string # Used for inline-editing: The comma-separated
                                                # titles of the child users of the group.
                   )

  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group User Page Workflow)
  is_navable
  has_profile_fields

  after_create     :import_default_group_structure

  include GroupMixins::SpecialGroups
  include GroupMixins::Import

  
  # General Properties
  # ==========================================================================================

  # The title of the group, i.e. a kind of caption, e.g. used in the <title> tag of the
  # webpage. By default, this returns just the name of the group. But this may be changed
  # in the main application.
  # 
  def title
    self.name
  end


  # Associated Objects
  # ==========================================================================================

  # Workflows
  # ------------------------------------------------------------------------------------------

  def descendant_workflows
    Workflow
      .joins( :links_as_descendant )
      .where( :dag_links => { :ancestor_type => "Group", :ancestor_id => self.id } )
      .uniq
  end

  def child_workflows
    self.descendant_workflows.where( :dag_links => { direct: true } )
  end


  # Users
  # ------------------------------------------------------------------------------------------

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



  # Groups
  # ------------------------------------------------------------------------------------------

  def descendant_groups_by_name( descendant_group_name )
    self.descendant_groups.where( :name => descendant_group_name )
  end


  # User Group Memberships
  # ------------------------------------------------------------------------------------------

  def memberships
    UserGroupMembership.find_all_by_group self 
  end

  def membership_of( user )
    UserGroupMembership.find_by_user_and_group( user, self )
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




  # ActiveRecord Callbacks
  # ==========================================================================================

  # Import the default group structure. 
  # This is called after creation of the group. 
  # 
  # The structure is to be placed in a file at 
  #   #{Rails.root}/import/default_group_sub_structures/#{self.name}.yml
  # and is to be formatted in yaml, like this:
  #  
  #   - Group 1
  #   - Group 2:
  #       - Group 2.1:
  #           - Group 2.1.1
  #           - Group 2.1.2
  #       - Group 2.2
  #   - Group 3:
  #       - Group 3.1
  #
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



  # Import Helpers
  # ==========================================================================================

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
        g.set_flags_based_on_group_name
        g.save
        self.hash_array_import_groups_into_parent_group sub_group_hash_array, g if sub_group_hash_array
        counter_for_created_groups += 1
      end
    end
    return counter_for_created_groups.to_s + " groups created."
  end

  def set_flags_based_on_group_name # TODO!
    if self.name == "Amtsträger"
      self.add_flag( :officers_parent )
    end
  end


  



  # Finder Methods
  # ==========================================================================================

  def self.first
    self.all.first.becomes self
  end

  def self.last
    self.all.last.becomes self
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
