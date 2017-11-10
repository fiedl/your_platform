class Graph::Node < Graph::Base

  def sync
    self.class.retry_on_end_of_file_error do
      self.class.write_object @object, node_label, properties
    end
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
    sync_flags(object, type)
    node
  end

  def self.sync_flags(object, type)
    if object.respond_to?(:flags)
      neo.execute_query("
        match (n:#{type} {id: #{object.id}})
        set n.flags = #{"['" + object.flags.join("', '") + "']"}
        return n
      ")
    end
  end

  def self.get_object_node(object, type)
    neo.find_nodes_labeled(type, id: object.id).first
  end

end