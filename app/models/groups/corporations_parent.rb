class Groups::CorporationsParent < Groups::GroupOfGroups
  after_create { self.add_flag(:corporations_parent); self.add_flag(:group_of_groups) }

  def self.find_or_create
    self.first || self.create
  end

end