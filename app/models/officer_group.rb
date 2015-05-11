class OfficerGroup < Group
  #attr_accessor :scope_id, :scope_type
  #attr_accessible :scope_id, :scope_type
  #after_save :apply_scope_id_and_type
  
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
  
  #def apply_scope_id_and_type
  #  if scope_id && scope_type
  #    scope_type = (['Group', 'Page'] & [params[:scope_type]]).first
  #    self.move_to scope_type.constantize.find(scope_id).officers_parent
  #  end
  #end
  
  
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