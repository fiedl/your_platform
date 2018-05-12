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

  class_methods do
    def by_contributor(user)
      ids = BlogPost.where(author_user_id: user.id).pluck(:id)
      host_or_guest_group_ids_of_this_user = (user.groups.flagged(:hosts).pluck(:id) + user.groups.flagged(:guests).pluck(:id))
      ids += Page.find(Group.where(id: host_or_guest_group_ids_of_this_user).includes(:links_as_child).where(dag_links: {ancestor_type: "Page"}).pluck('dag_links.ancestor_id'))
      self.where(id: ids.uniq)
    end
  end

end