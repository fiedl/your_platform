class Graph::User < Graph::Node

  def user
    @object
  end

  def node_label
    "User"
  end

  def properties
    {id: user.id, name: user.name.to_s, title: user.title.to_s, first_name: user.first_name.to_s, last_name: user.last_name.to_s, name_affix: user.name_affix.to_s}
  end

end