concern :GroupGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    Graph::Group.sync self
  end

end
