class Graph::Link < Graph::Base

  def link
    @object
  end

  def link_label
    raise 'please define link_label in subclass'
  end

  def properties
    {}
  end

  def sync
    self.class.retry_on_end_of_file_error do
      write_link
    end
  end

  def delete
    execute_query("
      match (:#{namespace})-[r:#{link_label} {id: #{link.id}}]-(:#{namespace})
      delete r
    ")
  end

  def write_link
    attributes = properties.merge({id: link.id, gid: link.gid})
    neo.reset_relationship_properties(find_or_create_link_id, attributes)
  end

  def find_or_create_link_id
    find_link_id || create_link_id
  end
  def find_link_id
    query_ids("
      match (:#{namespace})-[r:#{link_label}]-(:#{namespace})
      where r.id = #{link.id}
      return ID(r)
    ").first
  end
  def create_link_id
    neo.create_relationship link_label, parent_node, child_node, {id: link.id}
    find_link_id
  end

end