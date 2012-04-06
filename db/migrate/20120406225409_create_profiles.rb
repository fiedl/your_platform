# -*- coding: utf-8 -*-
class CreateProfiles < ActiveRecord::Migration
  #def change
  #  create_table :profiles do |t|
  #
  #    t.timestamps
  #  end
  #end

  # Brauche ich hier wirklich eine eigene Tabelle?
  # Was soll die denn tun, außer Benutzer und Profilfelder zu verknüpfen? 
  # Dazu brauche ich keine eigene Tabelle. Es könnte einfach beim Profilfeld eine user_id gepspeichert bleiben,
  # wie es jetzt schon ist.
  # Die Frage ist, ob in dieser Datenbank noch etwas anderes gespeichert wird pro Benutzer. 

  # Im Moment sieht es nicht so aus, als bräuchte ich eine eigene Tabelle.
  # Daher ist hier alles auskommentiert.
  # -- SF 2012-04-11

end
