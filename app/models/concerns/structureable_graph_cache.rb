# A lot of methods, which have a result that depends on the graph,
# are cached.
#
#     class GraphNode
#       is_structureable
# 
#       def some_method_depending_on_the_graph
#         cached { calculate_result(...) }
#       end
#     end
#
# But this means that the graph-related cache has to be re-calculated
# whenever the graph changes. We can't re-calculate the whole graph
# whenever some small part changes, since this would be too expensive.
#
# Instead, the methods in this file determine which parts of the grpah
# are affacted by a change, and, which caches are to be re-calculated
# in response.
#
concern :StructureableGraphCache do
  
  concerning :OfficerHasChanged do
    def refresh_cache_after_officer_has_changed
      affected_nodes_after_officer_has_changed
      .refresh_cached :find_admins
      .refresh_cached :officers_of_self_and_parent_groups
      
      # TODO: `refresh_role_cache`
    end
    
    def affected_nodes_after_officer_has_changed
      ([self] + connected_descendant_groups).collect do |structureable|
        [structureable] + structureable.connected_descendant_pages + structureable.child_events + structureable.child_users
      end.flatten
    end
  end
  
  concerning :MembershipHasChanged do
    def refresh_cache_after_membership_has_changed
      affected_nodes_after_membership_has_changed
      .refresh_cached :members
      .refresh_cached :memberships
    end
    
    def affected_nodes_after_membership_has_changed
      connected_ancestor_groups
    end
  end
  
  concerning :SubgroupHasChanged do
    def refresh_cache_after_subgroup_has_changed
      affected_nodes_after_subgroup_has_changed
      .refresh_cached :connected_descendant_groups
      .refresh_cached :members
      .refresh_cached :memberships
    end
    
    def affected_nodes_after_subgroup_has_changed
      connected_ancestor_groups
    end
  end
  
end