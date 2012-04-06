# -*- coding: utf-8 -*-
class Profile #< ActiveRecord::Base
  # attr_accessible :title, :body

  #belongs_to            :user

  #has_many              :profile_fields

  def initialize( user )
    @user = user
  end

  def fields
    ProfileField.find( :all, :conditions => "user_id = '#{@user.id}'" )
  end

  def email
    begin
      @email = email_field.value unless @email
    rescue
      @email = nil
    end
    return @email
  end
  def email=( email )
    @email = email
    # Dieser Wert wird erst später gepspeichert, wenn ein save() aufgerufen wird.
    
    # TODO: Hier ist die Frage, wie das getriggert wird, nachdem dies kein echter ActiveRecord ist. 
  end


  def save
    if @email
      unless @email.blank?
        pf = email_field
        unless pf
          pf = ProfileField.new( :user_id => @user.id, :type => "Email", :label => I18n.t( :email ) )
        end
        unless pf.value == @email
          pf.value = @email
          pf.save
        end
      end
    end
  end

  private

  def email_field
    ProfileField.find( :first, :conditions => "user_id='#{@user.id}' AND type='Email'" ) 
  end

end
