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

  def extensive_name
    if scope.respond_to? :extensive_name
      "#{title}, #{scope.extensive_name}"
    elsif scope.respond_to? :title
      "#{title}, #{scope.title}"
    else
      super
    end
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