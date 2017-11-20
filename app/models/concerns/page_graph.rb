concern :PageGraph do

  included do
    after_save :sync_to_graph_database
    before_destroy { Graph::Page.find(self).delete }
  end

  def sync_to_graph_database
    Graph::Page.sync self
  end

end