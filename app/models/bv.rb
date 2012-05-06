class Bv
  
  def self.by_plz( plz )
    bv_name = BvMapping.find_by_plz( plz ).bv_name
    return ( Group.bvs.child_groups.select { |group| group.name == bv_name } ).first
  end

end
