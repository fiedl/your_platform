class Graph::Link < Graph::Base

  def link
    @object
  end

  def properties
    {id: link.id}
  end

  def sync
    self.class.retry_on_end_of_file_error do
      sync_parent
    end
    self.class.retry_on_end_of_file_error do
      sync_child
    end
    self.class.retry_on_end_of_file_error do
      write_link
    end
  end

  def get_link
    neo.execute_query("
      match ()-[r:#{self.class.relationship_type}]-()
      where r.id = #{@object.id}
      return r
    ")['data'].flatten.first
  end

  def write_link
    neo.set_relationship_properties link_id, properties
  end

  def link_id
    self.class.find_or_create(link)['metadata']['id']
  end

  def self.find_or_create(link)
    find(link).get_link || create(link)
  end

  def self.create(link)
    self.new(link).create_link
  end

  def create_link
    neo.create_relationship self.class.relationship_type, parent_node, child_node, properties
  end

end