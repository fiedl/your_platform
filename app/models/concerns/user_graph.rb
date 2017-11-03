concern :UserGraph do

  included do
    after_save :sync_to_graph_database
  end

  def sync_to_graph_database
    GraphDatabase::User.sync self
  end

end
