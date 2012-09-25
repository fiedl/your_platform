# -*- coding: utf-8 -*-
# Wingolf-am-Hochschulort-Gruppe
class Wah < Corporation

  def self.all
    Group.find_corporation_groups.collect do |group|
      group.becomes Wah
    end
  end

  def aktivitas
    self.child_groups.select { |child| child.name == "Aktivitas" or child.name == "Activitas" }.first
  end

  def philisterschaft
    self.child_groups.select { |child| child.name == "Philisterschaft" }.first

    # TODO: Jeder kann diese Gruppen umbenennen. Vieleicht sollten Gruppen ein Special-Attribut bekommen, das beim Umbenennen
    # dann ja nicht geändert wird. Auf diese Weise kann man auch leichter suchen: find_by_special( "Jeder" ).

  end

  def hausverein
    self.child_groups.select{ |child| child.name == "Hausverein" or child.name == "Wohnheimsverein" }.first
  end

  def memberships_for_the_corporate_vita_of( user )
    aktivitas_membership = UserGroupMembership.now_and_in_the_past
      .find_all_by( user: user, group: self.aktivitas ).first
    if aktivitas_membership
      aktivitas_sub_memberships = aktivitas_membership.direct_memberships_now_and_in_the_past 
    else
      aktivitas_sub_memberships = []
    end
    philisterschaft_membership = UserGroupMembership.now_and_in_the_past
      .find_all_by( user: user, group: self.philisterschaft ).first
    if philisterschaft_membership
      philisterschaft_sub_memberships = philisterschaft_membership.direct_memberships_now_and_in_the_past 
    else
      philisterschaft_sub_memberships = []
    end
    return aktivitas_sub_memberships + philisterschaft_sub_memberships
  end

end
