# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible          :first_name, :last_name, :alias, :email

  validates_presence_of    :first_name, :last_name, :alias
  validates_uniqueness_of  :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of      :email, :with => /^[a-z0-9_.-]+@[a-z0-9-]+\.[a-z.]+$/i, :if => Proc.new { |user| user.email }

  after_save               :save_email
  before_save              :generate_alias_if_necessary, :capitalize_name

  def alias
    a = Alias.new( read_attribute :alias ) if read_attribute :alias
    a = Alias.new unless a
    a.user = self
    return a
  end

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

  def capitalize_name
    first_name.capitalize!
    last_name.capitalize! unless last_name.include?( " " ) # "de Silva"
    self.name
  end

  private

  def email_profile_field
    ProfileField.find( :first, :conditions => "user_id='#{id}' AND type='Email'" )
  end

  def save_email
    if @email
      unless @email.blank?
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

  def generate_alias_if_necessary
    self.alias.generate! if self.alias.blank?
  end

end

class Alias < String

  def generate( user = nil )
    user = @user unless user
    if user
      if User.find( :all, :conditions => "last_name='#{user.last_name}' AND id!='#{user.id}'" ).count == 0
        # Wenn der Nachname nur einmal vorkommt, wird dieser als Alias vorgeschlagen.      
        suggestion = Alias.new user.last_name.downcase # mustermann
      elsif User.find( 
                      :all, 
                      :conditions => "last_name='#{user.last_name}' 
                                      AND first_name LIKE '#{user.first_name.first}%' 
                                      AND id!='#{user.id}'" 
                      ).count == 0
        # Wenn der erste Buchstabe des Vornamens den Nutzer eindeutig identifiziert:
        suggestion = Alias.new user.first_name.downcase.first + "." + user.last_name.downcase # m.mustermann
      else
        suggestion = Alias.new user.first_name.downcase + "." + user.last_name.downcase # max.mustermann            
      end
      # Wenn dies immernoch nicht ausreicht, wird das ganze zu einem Fehler führen, 
      # da der Alias weder leer noch bereits vorhanden sein darf.
      # Der Benutzer wird dann aufgefordert, einen anderen Alias zu wählen.
      return suggestion
    end
  end

  def generate!( user = nil )
    user = @user unless user
    if user
      user.alias = user.alias.generate
    end
  end

  def taken?
    User.find( :all, :conditions => "alias='#{self}'" ).size > 0
  end

  def user=( user )
    @user = user
  end

end
