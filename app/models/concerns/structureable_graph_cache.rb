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
    end
    
    def affected_nodes_after_officer_has_changed
      ([self] + connected_descendant_groups).collect do |structureable|
        [structureable] + structureable.connected_descendant_pages + structureable.child_events + structureable.child_users
      end.flatten
    end
  end
  
  concerning :MembershipHasChanged do
    def refresh_cache_after_membership_has_changed
    end
    
    def affected_nodes_after_membership_has_changed
    end
  end
  
  concerning :SubgroupHasChanged do
    def refresh_cache_after_subgroup_has_changed
    end
    
    def affected_nodes_after_subgroup_has_changed
    end
  end
  
  concerning :SupergroupHasChanged do  
    def refresh_cache_after_supergroup_has_changed
    end
    
    def affected_nodes_after_supergroup_has_changed
    end
  end
  
end