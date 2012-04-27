# -*- coding: utf-8 -*-

require 'user_property_string'

class UserAlias < UserPropertyString

  def generate
    if @user && @user.first_name && @user.last_name
      if User.find( :all, :conditions => "last_name='#{@user.last_name}' AND id!='#{@user.id}'" ).count == 0
        # Wenn der Nachname nur einmal vorkommt, wird dieser als Alias vorgeschlagen.      
        suggestion = Alias.new @user.last_name.downcase # mustermann
      elsif User.find( 
                      :all, 
                      :conditions => "last_name='#{@user.last_name}' 
                                      AND first_name LIKE '#{@user.first_name.first}%' 
                                      AND id!='#{@user.id}'" 
                      ).count == 0
        # Wenn der erste Buchstabe des Vornamens den Nutzer eindeutig identifiziert:
        suggestion = UserAlias.new @user.first_name.downcase.first + "." + @user.last_name.downcase # m.mustermann
      else
        suggestion = UserAlias.new @user.first_name.downcase + "." + @user.last_name.downcase # max.mustermann            
      end
      # Wenn dies immernoch nicht ausreicht, wird das ganze zu einem Fehler führen, 
      # da der Alias weder leer noch bereits vorhanden sein darf.
      # Der Benutzer wird dann aufgefordert, einen anderen Alias zu wählen.
      return suggestion
    end
  end

  def generate!
    replace generate
  end

  def taken?
    User.find( :all, :conditions => "alias='#{self}'" ).size > 0
  end

end



