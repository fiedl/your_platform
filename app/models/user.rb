# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible          :first_name, :last_name, :alias, :email
  validates_presence_of    :first_name, :last_name
  after_save               :save_email

  def name
    first_name + " " + last_name 
  end

  def email
    begin
      @email = email_profile_field.value unless @email
    rescue
      @email = nil
    end
    return @email
  end
  def email=(email)
    @email = email
    # Dieser Wert wird erst später gesichert, wenn User.save() aufgerufen wird.
  end

  def profile_fields
    ProfileField.find( :all, :conditions => "user_id = '#{id}'" ) 
  end

  private

  def email_profile_field
    ProfileField.find( :first, :conditions => "user_id='#{id}' AND type='Email'" )
  end

  def save_email
    if @email
      pf = email_profile_field
      unless pf
        pf = ProfileField.new( :user_id => id, :type => "Email", :label => "E-Mail" )
      end
      unless pf.value == @email
        pf.value = @email
        pf.save
      end
    end
  end

end
