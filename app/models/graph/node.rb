class Graph::Node < Graph::Base

  def sync
    self.class.write_object @object, node_label, properties
  end

  def self.get_node(object)
    self.new(object).get_node
  end

  def get_node
    self.class.get_object_node @object, node_label
  end

  def self.write_object(object, type, attributes = nil)
    node = get_object_node(object, type) || neo.create_node
    attributes ||= {name: object.name.to_s}
    attributes = attributes.merge({id: object.id, url: object.url, gid: object.gid})
    neo.reset_node_properties node, attributes
    neo.set_label node, type
    node
  end

  def self.get_object_node(object, type)
    neo.find_nodes_labeled(type, id: object.id).first
  end

end