# -*- coding: utf-8 -*-

# This extends the your_platform Group model.
require_dependency YourPlatform::Engine.root.join( 'app/models/group' ).to_s

# This class represents a group of the platform.
# While the most part of the group class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the group model.

class Group
  
  # This method is called by a nightly rake task to renew the cache of this object.
  #
  def fill_cache

    # Memberships
    memberships_for_member_list
    memberships_this_year
    latest_memberships
        
    # Other Groups
    leaf_groups
    corporation
    
    # Address Labels
    cached_members_postal_addresses
    cached_members_postal_addresses_created_at

  end
  

  # Special Groups
  # ==========================================================================================

  # Erstbandphilister
  # ------------------------------------------------------------------------------------------

  include GroupMixins::Erstbandphilister


  # BVs
  # ------------------------------------------------------------------------------------------

  def self.find_bvs_parent_group
    find_special_group(:bvs_parent)
  end
  
  def self.create_bvs_parent_group
    bvs_parent_group = create_special_group(:bvs_parent)
    bvs_parent_group.parent_pages << Page.intranet_root
    return bvs_parent_group
  end

  def self.find_or_create_bvs_parent_group
    find_or_create_special_group(:bvs_parent)
  end
  
  def self.bvs_parent
    find_or_create_bvs_parent_group
  end
  
  def self.bvs_parent!
    find_bvs_parent_group || raise('special group :bvs_parent does not exist.')
  end

  def self.bvs
    self.find_bv_groups
  end

  def self.find_bv_groups
    (self.find_bvs_parent_group.try(:child_groups) || [])
  end

  # Wingolfsblätter-Abonnenten
  # ------------------------------------------------------------------------------------------

  def self.wbl_abo_group
    Group.find_by_flag(:wbl_abo)
  end

  def self.find_or_create_wbl_abo_group
    if self.wbl_abo_group
      return self.wbl_abo_group 
    else
      wbl_page = Page.find_by_title("Wingolfsblätter")
      wbl_page ||= Page.find_or_create_intranet_root.child_pages.create(title: "Wingolfsblätter")
      group = wbl_page.child_groups.where(name: "Abonnenten").first
      group ||= wbl_page.child_groups.create(name: "Abonnenten")
      group.add_flag :wbl_abo
      return group
    end
  end
 
  def self.wbl_abo
    self.find_or_create_wbl_abo_group
  end

  def self.wbl_abo!
    self.wbl_abo_group
  end

  # This returns whether the group is special.
  # This means that the group is special, e.g.
  # an officers group or a Wingolfsblätter-Abonnenten or
  # BV
  def is_special_group?
    self.has_flag?( :wbl_abo ) or
    self.has_flag?( :bvs_parent ) or
    self.has_flag?( :officers_parent ) or
    self.ancestor_groups.select do |ancestor|
      ancestor.has_flag?(:officers_parent)
    end.any? or
    self.ancestor_groups.select do |ancestor|
      ancestor.has_flag?(:bvs_parent)
    end.any?
  end
  
  
  # In member lists of corporations do not show
  # former and deceased members as well as members
  # of special groups associated with this corporation
  # as subgroups---such as certain mailing lists.
  #
  def memberships_for_member_list
    cached do
      if corporation?
        aktivitas_and_philisterschaft_member_ids = 
          (becomes(Corporation).aktivitas.try(:member_ids) || []) + 
          (becomes(Corporation).philisterschaft.try(:member_ids) || [])
        memberships.where(descendant_id: aktivitas_and_philisterschaft_member_ids)
      else
        memberships_including_members
      end
    end
  end
  
  
  
  def self.alle_aktiven
    self.find_or_create_special_group :alle_aktiven
  end
  def self.alle_philister
    self.find_or_create_special_group :alle_philister
  end


end

