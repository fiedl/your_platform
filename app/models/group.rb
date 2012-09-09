# -*- coding: utf-8 -*-

# This extends the your_platform Group model.
require_dependency YourPlatform::Engine.root.join( 'app/models/group' ).to_s

# This class represents a group of the platform.
# While the most part of the group class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the group model.

class Group

  # Associated Objects
  # ==========================================================================================
  
  # Just the German-named alias method for officers of the group.
  # 
  def amtsträger
    officers
  end


  # Special Groups
  # ==========================================================================================

  def self.jeder
    self.find_everyone_group
  end
  
  def self.jeder!
    unless self.jeder
      p "Creating group 'Jeder' ..."
      Group.create( name: "Jeder" )
    end
    return self.jeder
  end

  def self.wingolf_am_hochschulort
    self.corporations_parent
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

  def self.bvs_parent
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

  
  # Finder Methods
  # ==========================================================================================

  def self.find_wah_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_groups = Group.wingolf_am_hochschulort.child_groups if Group.wingolf_am_hochschulort
    return ancestor_groups & wah_groups if ancestor_groups and wah_groups
  end

  def self.find_wah_branch_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_branch = Group.wingolf_am_hochschulort.descendant_groups if Group.wingolf_am_hochschulort
    return ancestor_groups & wah_branch if ancestor_groups and wah_branch
  end

  def self.find_non_wah_branch_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_branch = Group.wingolf_am_hochschulort.descendant_groups if Group.wingolf_am_hochschulort
    wah_branch = [] unless wah_branch
    return ancestor_groups - wah_branch
  end


  def self.find_bvs_parent
    self.bvs_parent
  end

  def self.find_bvs
    self.find_bvs_parent.child_groups
  end


end

