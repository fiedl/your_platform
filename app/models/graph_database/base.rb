class GraphDatabase::Base

  def self.neo
    @neo ||= Neography::Rest.new authentication: :basic, username: 'neo4j', password: 'trinity'
  end

  def neo
    self.class.neo
  end

  def self.sync(object)
    self.new(object).sync
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