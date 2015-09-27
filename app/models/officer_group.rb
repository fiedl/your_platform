class OfficerGroup < Group
  
  def scope
    # The scope of responsibility of the officers is defined by
    # the structureable (Group, Page) the officer is officer of.
    structureable
  end
  
  def structureable
    scope_group || scope_page
  end
  
  # This is the group the officer is responsible for.
  #
  def scope_group
    parent.parent_groups.first
  end
  
  # This is the page the officer is responsible for.
  #
  def scope_page
    parent.parent_pages.first
  end
  
  def parent
    ancestor_groups.flagged(:officers_parent).first || raise('officers group has no officers_parent!')
  end
  
  
  def self.patch_officer_groups
    officer_groups = Group.flagged(:officers_parent).collect { |officers_parent| officers_parent.descendant_groups }.flatten
    officer_groups.each do |officer_group| 
      updated_at = officer_group.updated_at
      officer_group.update_attribute :type, 'OfficerGroup'
      officer_group.update_attribute :updated_at, updated_at
    end
    officer_groups.count
  end
end