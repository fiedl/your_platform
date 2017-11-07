concern :DagLinkGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    if self.direct?
      Graph::HasSubgroup.sync self if ancestor.kind_of?(Group) && descendant.kind_of?(Group)
      Graph::Membership.sync self if ancestor.kind_of?(Group) && descendant.kind_of?(User)
      Graph::HasSubpage.sync self if ancestor.kind_of?(Page) && descendant.kind_of?(Page)
      Graph::GroupHasPage.sync self if ancestor.kind_of?(Group) && descendant.kind_of?(Page)
      Graph::PageHasGroup.sync self if ancestor.kind_of?(Page) && descendant.kind_of?(Group)
    end
  end

end