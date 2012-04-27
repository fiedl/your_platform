# -*- coding: utf-8 -*-

# Diese Klasse repräsentiert den Vorgang der Identifikation eines Benutzers.
# Benutzer können sich auf verschiedene Arten identifizieren, z.B. durch Vor- und Zunamen, oder durch ihre E-Mail-Adresse.
# Siehe auch possible_attributes, find_users.
class UserIdentification

  def initialize( user )
    @user = user
  end

  # Mit diesen Benutzer-Attributen kann sich ein Benutzer identifizieren.
  def self.possible_attributes
    [ :alias, :last_name, :name, :email ]
  end

  def self.find_users_by_attribute( attribute_name, attribute_value )
    users = []
    if User.column_names.include? attribute_name.to_s
      # Wenn es eine SQL-Tabellenspalte ist, kann SQL zum (schnelleren) Suchen benutzt werden.                                      
      users = User.send "find_all_by_#{attribute_name.to_s}", attribute_value
    else
      # Wenn es keine Tabellenspalte ist, müssen erst alle Objekte in ein Array geladen                                             
      # und dann gefltert werden.                                                                                                   
      User.find_each do |u|
        result = u.send attribute_name.to_s
        users << u if result.downcase == attribute_value.downcase if result
      end
    end
    return users
  end

  # Alle Benutzer anhand eines Identifikationsstrings finden, z.B. Name oder E-Mail-Adresse.
  def self.find_users( identification_string )
    users = []
    self.possible_attributes.each do |attribute_name|
      users += self.find_users_by_attribute( attribute_name, identification_string )
    end
    return users
  end

end
