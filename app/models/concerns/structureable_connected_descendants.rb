concern :StructureableConnectedDescendants do

  def connected_descendants
    connected_descendant_groups.collect do |g|
      [g] + g.members.to_a + g.connected_descendant_pages + g.child_events
    end.flatten.uniq
  end

end