class Groups::CorporationsParent < Groups::GroupOfGroups
  after_create { self.add_flag(:corporations_parent); self.add_flag(:group_of_groups) }

  def self.find_or_create
    # I don't know why `self.create` does not work. TODO: Check again when migrated to rails 5.
    self.first || Group.create(type: self.name)
  end

end