class Graph::Base

  def self.neo
    # Configure the rest interface in an initializer.
    #
    #     # config/initializers/neo4j.rb
    #     Rails.configuration.x.neo4j_rest_url = "http://neo4j:swordfish@localhost:7474"
    #
    @neo ||= (Neography::Rest.new(Rails.configuration.x.neo4j_rest_url) if configured?)
  end

  def self.configured?
    Rails.configuration.x.neo4j_rest_url
  end

  def neo
    self.class.neo
  end

  # Neo4j has no namespacing and only has one single database.
  # This makes stages and even multi tenancy a bit more difficult.
  #
  # To support use cases where several distinct graph databases
  # are needed, we use the rails environment as example namespace.
  #
  # Namespaces are applied by adding the namespace as additional label
  # to each graph node. Therefore, each query must add this to the
  # starting node.
  #
  #     execute_query("match (n:Group:#{namespace})")
  #
  # Don't be afraid. `execute_query` will warn you if the namespace
  # is missing from the query string.
  #
  def self.namespace
    ApplicationRecord.storage_namespace
  end

  def namespace
    self.class.namespace
  end

  def self.execute_query(query)
    if configured?
      raise 'namespace is missing in query string' if not query.include? ":#{namespace}"
      self.retry_on_end_of_file_error do
        Rails.logger.debug "NEO4J: #{query}"
        neo.execute_query query
      end
    else
      p "Neo4j: Not executing query, because neo4j connection is not configured: #{query}"
    end
  end

  def execute_query(query)
    self.class.execute_query query
  end

  def self.sync(object)
    self.new(object).sync if self.configured?
  end

  def initialize(object)
    @object = object
  end

  def self.find(object)
    self.new(object)
  end

  def self.clean(confirmation = nil)
    self.delete_all_nodes_and_relations(confirmation)
  end

  def self.delete_all_nodes_and_relations(confirmation = nil)
    if confirmation.to_s == "yes_i_am_sure"
      execute_query "MATCH (n:#{namespace}) DETACH DELETE n" # https://stackoverflow.com/a/21357473/2066546
    else
      raise 'please confirm with parameter :yes_i_am_sure'
    end
  end

  def query_ids(query)
    self.class.query_ids query
  end

  def self.query_ids(query)
    if configured?
      execute_query(query)['data'].flatten
    else
      []
    end
  end

  def self.import(group = nil)
    if group
      import_group_with_descendants(group)
    else
      import_everything
    end
  end

  def self.import_everything
    require 'fiedl/log'
    log = Fiedl::Log::Log.new

    log.head "Importing everything into the graph database"
    log.section "Groups"
    log.info "Importing #{::Group.count} groups ..."
    Group.find_each { |group| Graph::Group.sync(group); print "." }
    log.success "Done importing groups."

    log.section "Users"
    log.info "Importing #{::User.count} users ..."
    User.find_each { |user| Graph::User.sync(user); print "." }
    log.success "Done importing users."

    log.section "Pages"
    log.info "Importing #{::Page.count} pages ..."
    Page.find_each { |page| Graph::Page.sync(page); print "." }
    log.success "Done importing pages."

    log.section "DagLinks"
    log.info "Importing #{::DagLink.direct.count} direct dag links ..."
    DagLink.direct.find_each { |link| link.sync_to_graph_database; print "." }
    log.success "Done importing dag links."

    log.success "Everything has been imported into the graph database."
  end

  def self.import_group_with_descendants(group)
    Graph::Group.sync group
    group.descendant_groups.each { |g| Graph::Group.sync g }
    group.descendant_groups.each do |child|
      child.links_as_child.each do |link|
        if link.ancestor.kind_of?(Group) && link.ancestor.in?([group] + group.descendant_groups)
          Graph::HasSubgroup.sync link
        end
      end
    end
    group.members.each { |u| Graph::User.sync u }
    group.members.each do |user|
      user.links_as_child.each do |m|
        if m && m.direct && m.user && m.group && m.group.in?([group] + group.descendant_groups)
          Graph::Membership.sync m
        end
      end
    end
  end

  def self.retry_on_end_of_file_error
    counter = 0
    begin
      yield
    rescue Excon::Error::Socket
      p "Excon::Error::Socket: end of file reached (EOFError). Retrying."
      counter += 1
      if counter < 100
        retry
      else
        raise "Giving up on neo4j connection."
      end
    end
  end

end