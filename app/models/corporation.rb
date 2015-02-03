# -*- coding: utf-8 -*-

# This extends the your_platform Corporation model.
require_dependency YourPlatform::Engine.root.join( 'app/models/corporation' ).to_s
require_dependency Rails.root.join( 'app/models/aktivitas' ).to_s
require_dependency Rails.root.join( 'app/models/philisterschaft' ).to_s

# Wingolf-am-Hochschulort-Gruppe
class Corporation 
  
  def aktivitas
    self.child_groups.aktivitates.first
  end

  def philisterschaft
    self.child_groups.philisterschaften.first
  end

  def hausverein
    self.child_groups.select{ |child| child.name == "Hausverein" or child.name == "Wohnheimsverein" }.first
  end
  
  def verstorbene
    self.child_groups.where(name: "Verstorbene").first
  end
  
  def self.find_all_wingolf_corporations
    self.all.select do |corporation|
      not corporation.token.include? "!"  # Falkensteiner!
    end
  end
  
end
