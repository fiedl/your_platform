class Graph::Node < Graph::Base

  def sync
    self.class.retry_on_end_of_file_error do
      write_node
    end
  end

  def object
    @object
  end

  def node_label
    raise 'please define node_label in the subclass'
  end

  def properties
    {name: object.name.to_s}
  end

  # Update node properties or create node.
  #
  # In neo4j's terminology, `MERGE` ensures that the given
  # pattern exists, i.e. find or create.
  #
  # https://stackoverflow.com/q/25177788/2066546
  #
  def write_node
    attributes = properties.merge({id: object.id, url: object.url, gid: object.gid})
    neo.reset_node_properties(find_or_create_node, attributes)
    sync_flags
  end

  def find_or_create_node
    node_internal_id = query_ids("
      merge (n:#{node_label}:#{namespace} {id: #{object.id}})
      return ID(n)
    ").first
    neo.get_node(node_internal_id)
  end

  def read_node
    execute_query("
      match (n:#{node_label}:#{namespace} {id: #{object.id}})
      return n
    ")['data'].first
  end

  def sync_flags
    if object.respond_to?(:flags)
      execute_query("
        match (n:#{node_label}:#{namespace} {id: #{object.id}})
        set n.flags = #{"['" + object.flags.join("', '") + "']"}
        return n
      ")
    end
  end

end