concern :UserGraph do

  included do
    after_save :sync_to_graph_database
    before_destroy { Graph::User.find(self).delete }
  end

  def sync_to_graph_database
    Graph::User.sync self
  end

end
