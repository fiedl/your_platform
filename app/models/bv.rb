class Bv < Group
  
  default_scope -> { joins(:links_as_child).where(dag_links: {ancestor_type: 'Group', ancestor_id: Group.find_bvs_parent_group.id}) }
  
  # Override the model name. This is used for the generation of paths, i.e.
  # group_path rather than bv_path.
  # 
  def self.model_name
    Group.model_name
  end

  def self.by_plz( plz )
    bv_token = BvMapping.find_by_plz( plz ).bv_name if BvMapping.find_by_plz( plz )
    bv_group = ( Bv.all.select { |group| group.token == bv_token } ).first if bv_token
    return bv_group.becomes Bv if bv_group
  end

  def self.by_address( address )
    geo_location = GeoLocation.find_or_create_by_address( address )
    self.by_geo_location(geo_location)
  end

  def self.by_geo_location( geo_location )
    
    # Germany: Use PLZ to identify BV
    return self.by_plz(geo_location.plz) if geo_location.country_code == "DE"

    # Austria => BV 43
    return self.find_by_token("BV 43") if geo_location.country_code == "AT"

    # Estonia => BV 44
    return self.find_by_token("BV 44") if geo_location.country_code == "EE"

    # Rest of Europe => BV 45
    return self.find_by_token("BV 45") if geo_location.in_europe?

    # Rest of the World => BV 46
    return self.find_by_token("BV 46") if geo_location.country_code

    # No valid address given => BV 00
    return self.find_by_token("BV 00")

  end

  # Ordnet den +user+ diesem BV zu und trägt ihn ggf. aus seinem vorigen BV aus.
  #
  def assign_user( user, options = {} )
    Bv.unassign_user user
    super(user, options)

    # TODO: Hier muss noch der entsprechende Workflow später getriggert werden, 
    # damit die automatischen Benachrichtigungen versandt werden.
  end

  # Trägt einen Benutzer aus seinem eigenen BV aus.
  def self.unassign_user( user )
    old_bv = user.bv
    old_bv.try(:unassign_user, user)
  end

end
