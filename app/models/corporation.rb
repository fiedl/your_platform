# -*- coding: utf-8 -*-

# This extends the your_platform Corporation model.
require_dependency YourPlatform::Engine.root.join( 'app/models/corporation' ).to_s

# Wingolf-am-Hochschulort-Gruppe
class Corporation 

  def self.all
    Group.find_corporation_groups.collect do |group|
      group.becomes Corporation
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

end
