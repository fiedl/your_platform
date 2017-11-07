concern :PageGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    Graph::Page.sync self
  end

end