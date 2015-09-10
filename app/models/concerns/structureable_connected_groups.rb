# This extends the Structureabe objects by methods that deal with connected groups,
# which are groups that are related to the structureable object by other groups,
# but not via events or other non-group objects.
#
# Example:
# 
#     group1
#       |---- group2 --- group3
#       |---- event1
#               |------ attendees_group
#
#   In the example, groups 1, 2, and 3 are connected groups. But the attendees_group
#   is not connected to them, because a non-group object, event1, is in between.
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
    cached { (parent_group_ids + parent_groups.collect(&:connected_ancestor_group_ids).flatten).uniq }
  end
  
  def connected_descendant_groups
    Group.find connected_descendant_group_ids
  end
  
  def connected_descendant_group_ids
    cached { (child_group_ids + child_groups.collect(&:connected_descendant_group_ids).flatten).uniq }
  end
  
end