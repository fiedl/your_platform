# This extends the Structureabe objects by methods that deal with connected groups,
# which are groups that are related to the structureable object by other groups,
# but not via events or other non-group objects.
#
# Example:
# 
#     group1
#       |---- group2 --- group3 --------------
#       |---- event1                          |
#       |       |------ attendees_group ---- user1
#       |
#     officers_parent ---- officer_group --- user2     
#
#   In the example, groups 1, 2, and 3 are connected groups. But the attendees_group
#   is not connected to them, because a non-group object, event1, is in between.
#
#   Despite `officers_parent` being a group, `user2` is not regarded as
#   connected to `group1`, since officers aren't necessarily members of a group.
#
# The here implemented mechanism should be independent of the DagLink model,
# i.e. can only ask for directly connected objects. Therefore, it relies on caching
# rather than indirect graph connections to achieve the neccessary read performance.
#
concern :StructureableConnectedGroups do
  
  def connected_ancestor_groups
    Group.find connected_ancestor_group_ids
  end
  
  def connected_ancestor_group_ids
    cached { select_connected_groups(parent_groups).collect { |parent_group| [parent_group.id] + parent_group.connected_ancestor_group_ids }.flatten.uniq }
  end
  
  def connected_descendant_groups
    Group.find connected_descendant_group_ids
  end
  
  def connected_descendant_group_ids
    cached { select_connected_groups(child_groups).collect { |child_group| [child_group.id] + child_group.connected_descendant_group_ids }.flatten.uniq }
  end
  
  def ancestor_groups(reload = false)
    @ancestor_groups = nil if reload
    @ancestor_groups ||= connected_ancestor_groups
  end
  
  def descendant_groups(reload = false)
    @descendant_groups = nil if reload
    @descendant_groups ||= connected_descendant_groups
  end
  
  private
  
  def select_connected_groups(groups)
    groups.select do |group|
      not group.has_flag? :officers_parent
    end
  end
  
end