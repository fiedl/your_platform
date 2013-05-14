# -*- coding: utf-8 -*-

# This extends the your_platform Group model.
require_dependency YourPlatform::Engine.root.join( 'app/models/group' ).to_s

# This class represents a group of the platform.
# While the most part of the group class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the group model.

class Group


  # Special Groups
  # ==========================================================================================

  # BVs
  # ------------------------------------------------------------------------------------------

  def self.bvs_parent
    self.find_bvs_parent_group
  end

  def self.bvs
    self.find_bv_groups
  end

  def self.find_bvs_parent_group
    Group.find_by_flag( :bvs_parent )
  end

  def self.find_bv_groups
    self.find_bvs_parent_group.child_groups
  end

  def self.create_bvs_parent_group
    bvs_parent = Group.create( name: "Bezirksverbände" )
    bvs_parent.add_flag( :bvs_parent )
    bvs_parent.parent_groups << Group.everyone
    bvs_parent.name = I18n.translate( :bvs_parent ) # "Bezirksverbände"
    bvs_parent.save
    return bvs_parent
  end

  
  # Wingolfsblätter-Abonnenten
  # ------------------------------------------------------------------------------------------

  def self.wbl_abo_group
    Group.find_by_flag(:wbl_abo)
  end

  def self.wbl_abo
    self.wbl_abo_group
  end

  def self.find_or_create_wbl_abo_group
    if self.wbl_abo_group
      return self.wbl_abo_group 
    else
      wbl_page = Page.find_by_title("Wingolfsblätter")
      wbl_page ||= Page.find_intranet_root.child_pages.create(title: "Wingolfsblätter")
      group = wbl_page.child_groups.where(name: "Abonnenten").first
      group ||= wbl_page.child_groups.create(name: "Abonnenten")
      group.add_flag :wbl_abo
      return group
    end
  end
 
  def self.wbl_abo!
    self.find_or_create_wbl_abo_group
  end


end

