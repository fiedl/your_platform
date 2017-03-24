concern :CorporationGroups do

  # Returns all regular groups. This excludes:
  #
  # - officers_parent
  # - attendees, contact_people
  #
  def groups
    descendant_groups.regular
  end

  # This method returns the status group with the given name.
  #
  def status_group(group_name)
    status_groups.where(name: group_name).first
  end

  def sub_group(group_name)
    descendant_groups.where(name: group_name).first
  end

end