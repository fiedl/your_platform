class OfficerGroup < Group
  
  def scope
    # The scope of responsibility of the officers is defined by
    # the structureable (Group, Page) the officer is officer of.
    structureable
  end
  
  def structureable
    parent.parent_groups.first || parent.parent_pages.first
  end
  
  def parent
    ancestor_groups.flagged(:officers_parent).first || raise('officers group has no officers_parent!')
  end
  
  
  def self.patch_officer_groups
    officer_groups = Group.flagged(:officers_parent).collect { |officers_parent| officers_parent.descendant_groups }.flatten
    officer_groups.each { |officer_group| officer_group.update_attribute :type, 'OfficerGroup' }
    officer_groups.count
  end
end