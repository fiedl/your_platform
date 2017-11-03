class GraphDatabase::User < GraphDatabase::Node

  def user
    @object
  end

  def node_label
    "User"
  end

  def properties
    {id: user.id, name: user.name.to_s, title: user.title.to_s}
  end

end