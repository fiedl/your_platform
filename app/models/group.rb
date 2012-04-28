# -*- coding: utf-8 -*-
class Group < ActiveRecord::Base
  attr_accessible :name, :token, :excessive_name

  has_dag_links    link_class_name: 'DagLink', ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group User Page)

  is_navable

  def title
    self.name
  end

  def self.jeder
    g = Group.find_by_name( "Jeder" )
    if g.root_for_groups?
      return g
    else
      return g.ancestor_groups.first
    end
  end

  def self.jeder!
    unless self.jeder
      p "Creating group 'Jeder' ..."
      Group.create( name: "Jeder" )
    end
    return self.jeder
  end

  def self.wingolf_am_hochschulort
    ( self.jeder.child_groups.select { |group| group.name == "Wingolf am Hochschulort" } ).first
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

end

class Groups 
  
  def self.all
    Group.all
  end

  def self.of_user( user )
    user.ancestor_groups
  end

end
