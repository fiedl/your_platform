# -*- coding: utf-8 -*-
class Bv < Group

  def self.all
    Group.find_bv_groups
  end

  def self.by_plz( plz )
    bv_token = BvMapping.find_by_plz( plz ).bv_name if BvMapping.find_by_plz( plz )
    bv_group = ( Bv.all.select { |group| group.token == bv_token } ).first if bv_token
    return bv_group.becomes Bv if bv_group
  end

  def self.by_address( address )
    address = address.becomes AddressString unless address.kind_of? AddressString
    return self.by_plz address.plz if address.country_code == "DE"
    return self.find_by_token "BV 43" if address.country_code == "AT" # Österreich
    return self.find_by_token "BV 44" if address.country_code == "EE" # Estland
    european_country_codes = %w(AD AL AT BA BE BG BY CH CY CZ DE DK EE ES FI FO FR GG GI GR GB HR HU IE IM IS IT JE LI LT LU LV MC MD MK MT NL NO PL PT RO RU SE SI SJ SK SM TR UA UK VA YU)
    return self.find_by_token "BV 45" if european_country_codes.include? address.country_code # Europa
    return self.find_by_token "BV 46" if address.country_code # Rest der Welt
    return self.find_by_token "BV 00" # Unbekannt verzogen
  end

  # Ordnet den +user+ diesem BV zu und trägt ihn ggf. aus seinem vorigen BV aus.
  def assign_user( user )
    Bv.unassign_user user

#    user.parent_groups << self
#    p "PARENT_GROUPS"
#    p user.parent_groups

    new_bv = self
    new_bv.child_users << user
    # TODO: Hier muss noch der entsprechende Workflow später getriggert werden, 
    # damit die automatischen Benachrichtigungen versandt werden.
  end

  # Trägt einen Benutzer aus seinem eigenen BV aus.
  def self.unassign_user( user )
    old_bv = user.bv
    if old_bv
      link = DagLink.find_edge( old_bv.becomes( Group ), user ) 
      link.destroy if link.destroyable? if link
    end
  end

end
