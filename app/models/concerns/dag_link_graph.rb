concern :DagLinkGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    GraphDatabase::HasSubgroup.sync self if ancestor.kind_of?(Group) && descendant.kind_of?(Group)
    GraphDatabase::Membership.sync self if ancestor.kind_of?(Group) && descendant.kind_of?(User)
  end

end