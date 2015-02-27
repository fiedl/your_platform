# -*- coding: utf-8 -*-

class Password < String
  
  PASSWORD_LENGTH = 12

  # This simply creates a new password using `pwgen`.
  # Example: 
  #     new_password = Password.generate
  def self.generate
    return pwgen_password if pwgen_password.length == PASSWORD_LENGTH
    return Passgen::generate( pronounceable: true )
  end
  
  # Example:
  #    new_password = Password.new
  #    new_password.generate!
  def generate!
    replace self.class.generate
  end

  def self.pwgen_password
    Password.new( `pwgen #{PASSWORD_LENGTH} -N 1 -n -c -B`.to_s[0..-2] )
  end

end


