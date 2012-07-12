# -*- coding: utf-8 -*-

class Password < String

  # This simply creates a new password using `pwgen`.
  # Example: 
  #     new_password = Password.generate
  def self.generate
    Password.new( `pwgen -N 1 -n -c -B`.to_s[0..-2] )
  end
  
  # Example:
  #    new_password = Password.new
  #    new_password.generate!
  def generate!
    replace self.class.generate
  end

end


