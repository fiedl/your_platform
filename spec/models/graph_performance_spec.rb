# This test creates and moves some groups in order to
# determine the graph performance.
#
# This is the same test as:
# https://github.com/fiedl/neo4j_ancestry_vs_acts_as_dag/blob/master/spec/performance_spec.rb
# https://github.com/fiedl/neo4j_gem_test/blob/master/spec/performance_spec.rb
#
require 'spec_helper'
require 'table-formatter'

if ENV['CI'] != 'travis'

  class TestGraph
    def initialize(params)
      @number_of_groups = params[:number_of_groups]
      @number_of_users = params[:number_of_users]
    end

    def create_groups
      @groups = (1..@number_of_groups).map { |n| Group.create(name: "Group #{n}") }
    end
    def groups
      @groups
    end

    def create_parent_group
      @parent_group = Group.create name: "Parent Group"
    end
    def parent_group
      @parent_group
    end

    def create_ancestor_group
      @ancestor_group = Group.create name: "Ancestor Group"
    end
    def ancestor_group
      @ancestor_group
    end

    def add_users_to_groups
      groups.each do |group|
        (1..@number_of_users).each { |n| group.child_users << FactoryGirl.create(:user) }
      end
    end

    def move_groups_into_parent_group
      groups.each do |group|
        parent_group.child_groups << group
      end
    end
    def move_parent_group_into_ancestor_group
      ancestor_group.child_groups << parent_group
    end
    def remove_the_link_of_the_ancestor_group
      ancestor_group.child_groups.destroy(parent_group)
    end


    def number_of_users_of_the_last_group
      groups.last.descendant_users.count
    end
    def number_of_parent_group_child_groups
      parent_group.child_groups.count
    end
    def number_of_ancestor_group_descendant_groups
      ancestor_group.descendant_groups.count
    end
    def number_of_ancestor_group_members
      ancestor_group.descendant_users.count
    end
    def number_of_parent_group_ancestor_groups
      parent_group.ancestor_groups.count
    end

    def find_ancestor_group_descendants
      ancestor_group.descendants.to_a
    end
    def find_ancestor_group_members
      ancestor_group.members.to_a
    end
    def find_connected_descendant_groups
      ancestor_group.connected_descendant_groups.to_a
    end

    def clear_graph
      DagLink.delete_all
    end
  end

  class Neo4jTestGraph < TestGraph
    def number_of_ancestor_group_descendant_groups
      ancestor_group.neo_node.query_as(:self).match("self-[*]->(g:Group)").pluck(:g).count
    end
    def number_of_parent_group_ancestor_groups
      parent_group.neo_node.query_as(:self).match("self<-[*]-(n)").pluck(:n).count
    end

    def find_ancestor_group_descendants
      ancestor_group.neo_node.query_as(:self).match("self-[*]->(n)").pluck(:n).collect { |n| n.to_active_record }
    end
    def find_ancestor_group_members
      User.find(ancestor_group.neo_node.query_as(:self).match("self-[*]->(u:User)").pluck('u.active_record_id'))
    end

    def clear_db
      # clear_model_memory_caches
      Neo4j::Session.current._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
    end
  end

  class ConnectedGroupsTestGraph < TestGraph
    def number_of_users_of_the_last_group
      groups.last.members.count
    end
    def number_of_ancestor_group_members
      ancestor_group.members.count
    end
  end

  describe "graph performance: " do

    $number_of_groups = 100
    $number_of_users = 10

    before :each do
      clear_db
    end

    let(:graph) {
      params = {number_of_groups: $number_of_groups, number_of_users: $number_of_users}
      if defined?(Neo4j)
        Neo4jTestGraph.new(params)
      elsif defined?(StructureableConnectedGroups)
        ConnectedGroupsTestGraph.new(params)
      else
        TestGraph.new(params)
      end
    }

    specify "creating #{$number_of_groups} groups" do
      benchmark { graph.create_groups }
      graph.groups.count.should == $number_of_groups
    end

    specify "adding #{$number_of_users} users to each of the #{$number_of_groups} groups" do
      graph.create_groups
      benchmark { graph.add_users_to_groups }
      graph.number_of_users_of_the_last_group.should == $number_of_users
    end

    specify "moving #{$number_of_groups} groups into a parent group" do
      graph.create_groups
      graph.create_parent_group
      benchmark { graph.move_groups_into_parent_group }
      graph.number_of_parent_group_child_groups.should == $number_of_groups
    end

    specify "moving the group structure into an ancestor group" do
      graph.create_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      benchmark { graph.move_parent_group_into_ancestor_group }
      graph.number_of_ancestor_group_descendant_groups.should == $number_of_groups + 1
    end

    specify "moving the groups with users into an ancestor group" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      benchmark { graph.move_parent_group_into_ancestor_group }
      graph.number_of_ancestor_group_descendant_groups.should == $number_of_groups + 1
      graph.number_of_ancestor_group_members.should == $number_of_groups * $number_of_users
    end

    specify "removing the link to the ancestor group" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      graph.move_parent_group_into_ancestor_group
      benchmark { graph.remove_the_link_of_the_ancestor_group }
      graph.number_of_ancestor_group_descendant_groups.should == 0
    end

    specify "destroying the ancestor group" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      graph.move_parent_group_into_ancestor_group
      benchmark { graph.ancestor_group.destroy }
      graph.number_of_parent_group_ancestor_groups.should == 0
    end

    specify "finding all #{$number_of_groups * $number_of_users} members" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      graph.move_parent_group_into_ancestor_group
      benchmark { graph.find_ancestor_group_members }
      benchmark("second run: finding all #{$number_of_groups * $number_of_users} members") { graph.find_ancestor_group_members }
      graph.find_ancestor_group_members.count.should == $number_of_groups * $number_of_users
      graph.find_ancestor_group_members.first.should be_kind_of User
    end

    specify "finding all connected descendant groups" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      graph.move_parent_group_into_ancestor_group
      benchmark { graph.find_connected_descendant_groups }
      benchmark("second run: all connected descendant groups") { graph.find_connected_descendant_groups }
      graph.find_connected_descendant_groups.count.should == $number_of_groups + 1
    end

    specify "creating 10 events for ancestor group" do
      graph.create_groups
      graph.add_users_to_groups
      graph.create_parent_group
      graph.move_groups_into_parent_group
      graph.create_ancestor_group
      graph.move_parent_group_into_ancestor_group
      benchmark do
        10.times { graph.ancestor_group.child_events.create }
      end
      graph.ancestor_group.events.count.should == 10
    end

    after(:all) do
      print_results
    end

    $results = []
    def benchmark(description = nil)
      duration_in_seconds = Benchmark.realtime {
        yield
      }.round(4)

      description ||= RSpec.current_example.metadata[:description] if RSpec.respond_to? :current_example  # rspec 3
      description ||= example.description  # rspec 2
      duration = "#{duration_in_seconds} seconds"

      $results << [description, "#{duration_in_seconds.to_s} s"]
      print "#{description}: #{duration}.\n".blue
    end

    def print_results
      print "\n\n## Results for #{ENV['BACKEND']}\n\n".blue.bold

      print "$number_of_groups = #{$number_of_groups}\n".blue
      print "$number_of_users  = #{$number_of_users}\n\n".blue

      print results_table.blue.bold
    end
    def results_table
      t = TableFormatter.new
      t.source = $results
      t.labels = ['Description', 'Duration']
      t.display.to_s
    end

    def clear_db
      graph.clear_graph
    end

  end
end