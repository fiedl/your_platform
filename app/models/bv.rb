# -*- coding: utf-8 -*-
class Bv
  
  def self.by_plz( plz )
    bv_token = BvMapping.find_by_plz( plz ).bv_name
    return ( Group.bvs.child_groups.select { |group| group.token == bv_token } ).first
  end

  def self.by_token( token )
    return ( Group.bvs.child_groups.select{ |group| group.token == token } ).first
  end

  def self.by_address( address )
    address = AddressString.new( address ) unless address.kind_of? AddressString
    return self.by_plz address.plz if address.country_code == "DE"
    return self.by_token "BV 43" if address.country_code == "AT" # Österreich
    return self.by_token "BV 44" if address.country_code == "EE" # Estland
    european_country_codes = %w(AD AL AT BA BE BG BY CH CY CZ DE DK EE ES FI FO FR GG GI GR HR HU IE IM IS IT JE LI LT LU LV MC MD MK MT NL NO PL PT RO RU SE SI SJ SK SM TR UA UK VA YU)
    return self.by_token "BV 45" if european_country_codes.include? address.country_code # Europa
    return self.by_token "BV 46" if address.country_code # Rest der Welt
    return self.by_token "BV 00" # Unbekannt verzogen
  end

end
