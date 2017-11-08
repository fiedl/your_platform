class Graph::Base

  def self.neo
    # Configure the rest interface in an initializer.
    #
    #     # config/initializers/neo4j.rb
    #     Rails.configuration.x.neo4j_rest_url = "http://neo4j:swordfish@localhost:7474"
    #
    @neo ||= Neography::Rest.new(Rails.configuration.x.neo4j_rest_url || raise('neo4j database connection not configured.'))
  end

  def self.configured?
    Rails.configuration.x.neo4j_rest_url
  end

  def neo
    self.class.neo
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
      neo.execute_query "MATCH (n) DETACH DELETE n" # https://stackoverflow.com/a/21357473/2066546
    else
      raise 'please confirm with parameter :yes_i_am_sure'
    end
  end

  def query_ids(query)
    neo.execute_query(query)['data'].flatten
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
    Group.find_each { |group| Graph::Group.sync group }
    log.success "Done importing groups."

    log.section "Users"
    log.info "Importing #{::User.count} users ..."
    User.find_each { |user| Graph::User.sync user }
    log.success "Done importing users."

    log.section "Pages"
    log.info "Importing #{::Page.count} pages ..."
    Page.find_each { |page| Graph::Page.sync page }
    log.success "Done importing pages."

    log.section "DagLinks"
    log.info "Importing #{::DagLink.direct.count} direct dag links ..."
    DagLink.direct.find_each { |link| link.sync_to_graph_database }
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
    begin
      yield
    rescue Excon::Error::Socket
      p "Excon::Error::Socket: end of file reached (EOFError). Retrying."
      retry
    end
  end

end