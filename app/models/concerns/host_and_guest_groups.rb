concern :HostAndGuestGroups do

  def hosts
    find_special_group(:hosts) ? hosts_group.members : []
  end

  def hosts_group
    find_or_create_special_group(:hosts)
  end

  def guests
    find_special_group(:guests) ? guests_group.members : []
  end

  def guests_group
    find_or_create_special_group(:guests)
  end

  def destroy
    find_special_group(:hosts).try(:destroy)
    find_special_group(:guests).try(:destroy)
    super
  end

  def contributors
    (super + hosts + guests).uniq
  end

end