concern :StructureableConnectedLeafGroups do
  
  def leaf_groups
    connected_leaf_groups
  end

  def connected_leaf_groups
    cached do
      connected_descendant_groups.select do |group|
        group.connected_descendant_groups.count == 0
      end
    end
  end
  
end