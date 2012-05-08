# -*- coding: utf-8 -*-
# Wingolf-am-Hochschulort-Gruppe
class Wah < Group

  def self.all
    Group.wingolf_am_hochschulort.child_groups
  end

  def aktivitas
    self.child_groups.select { |child| child.name == "Aktivitas" or child.name == "Activitas" }.first
  end

  def philisterschaft
    self.child_groups.select { |child| child.name == "Philisterschaft" }.first

    # TODO: Jeder kann diese Gruppen umbenennen. Vieleicht sollten Gruppen ein Special-Attribut bekommen, das beim Umbenennen
    # dann ja nicht geändert wird. Auf diese Weise kann man auch leichter suchen: find_by_special( "Jeder" ).

  end

end
