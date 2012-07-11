# -*- coding: utf-8 -*-
class UserPassword < UserPropertyString
  def self.generate
    UserPassword.new( `pwgen -N 1 -n -c -B`.to_s[0..-2], :user => @user )
  end
  
  def generate!
    replace self.class.generate
  end
end


