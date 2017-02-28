concern :CorporationGroups do

  # This method returns all status groups of the corporation.
  # In this general context, each leaf group of the corporation is a status group.
  # But this is likely to be overridden by the main application.
  #
  def status_groups
    Group.find status_group_ids
  end
  def status_group_ids
    StatusGroup.find_all_by_corporation(self).map(&:id)
  end

  # This method returns the status group with the given name.
  #
  def status_group(group_name)
    status_groups.select { |g| g.name == group_name }.first
  end

  def sub_group(group_name)
    descendant_groups.where(name: group_name).first
  end

end