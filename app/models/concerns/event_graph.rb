concern :EventGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    Graph::Event.sync self
  end

end