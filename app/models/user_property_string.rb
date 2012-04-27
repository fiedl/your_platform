# -*- coding: utf-8 -*-

# Manche Eigenschaften eines Benutzer, z.B. sein Alias oder sein Passwort basieren auf einem String,
# bringen jedoch weitere Methoden mit. Diese Eigenschaften leiten sich von dieser Klasse ab, wobei
# es die Aufgabe dieser Basisklasse ist, eine Instanzvariable @user zur Verfügung zu stellen, die
# den Benutzer, der die beschriebene Eigenschaft aufweist, repräsentiert.
class UserPropertyString < String

  attr_accessor :user

  def initialize( string = "", options = {} )
    string = "" unless string
    super( string )
    @user = options[ :user ]
  end

end

