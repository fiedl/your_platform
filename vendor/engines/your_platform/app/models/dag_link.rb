# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  def save( *args )
    delete_cache_daglink
    super( *args )
  end

  def delete_cache_daglink
    if self.descendant_type == "Group"
      if Group.exists?( self.descendant_id )
        desc_group = Group.find( self.descendant_id )
      end
    end
    if self.descendant_type == "Page"
      if Page.exists?( self.descendant_id )
        desc_page = Page.find( self.descendant_id )
      end
    end
    if self.descendant_type == "User"
      if User.exists?( self.descendant_id )
        desc_user = User.find( self.descendant_id )
      end
    end
    if desc_group || desc_page
      Rails.cache.delete([desc_group||desc_page, "structurable_admins"])
      Rails.cache.delete([desc_group||desc_page, "user_admins"])
    end
    if desc_user
      desc_user.delete_cache
    end

    # if ancestor group is admin group, also flush admins cache
    # for all descendant groups and pages of administred group or page
    if self.ancestor_type == "Group"
      if Group.exists?( self.ancestor_id )
        anc_group = Group.find( self.ancestor_id )
      end
    end
    if anc_group
      if anc_group.has_flag?( :admins_parent )
        officer_groups = anc_group.parent_groups.select { |x| x.has_flag?( :officers_parent ) } || []
        administreds = officer_groups.collect{ |x| x.parents }.flatten || []
        administred = administreds.try( :first )
        groups = administred.try( :descendant_groups ) || []
        groups.each do |x|
          Rails.cache.delete([x, "structurable_admins"])
          Rails.cache.delete([x, "user_admins"])
        end
        pages = administred.try( :descendant_pages ) || []
        pages.each do |x|
          Rails.cache.delete([x, "structurable_admins"])
          Rails.cache.delete([x, "user_admins"])
        end
      end
    end
  end

end
