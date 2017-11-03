class GraphDatabase::Base

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



  def self.import(group)
    GraphDatabase::Group.sync group
    group.descendant_groups.each { |g| GraphDatabase::Group.sync g }
    group.descendant_groups.each do |child|
      child.links_as_child.each do |link|
        if link.ancestor.kind_of?(Group) && link.ancestor.in?([group] + group.descendant_groups)
          GraphDatabase::HasSubgroup.sync link
        end
      end
    end
    group.members.each { |u| GraphDatabase::User.sync u }
    group.members.each do |user|
      user.links_as_child.each do |m|
        if m && m.direct && m.user && m.group && m.group.in?([group] + group.descendant_groups)
          GraphDatabase::Membership.sync m
        end
      end
    end
  end

end