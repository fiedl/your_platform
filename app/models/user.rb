# -*- coding: utf-8 -*-
class User < ActiveRecord::Base

  attr_accessible          :first_name, :last_name, :alias, :email

  validates_presence_of    :first_name, :last_name, :alias
  validates_uniqueness_of  :alias, :if => Proc.new { |user| ! user.alias.blank? }
  validates_format_of      :email, :with => /^[a-z0-9_.-]+@[a-z0-9-]+\.[a-z.]+$/i, :if => Proc.new { |user| user.email }

  after_save               :save_email
  before_save              :generate_alias_if_necessary, :capitalize_name

  def alias
    Alias.new( read_attribute :alias )
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
    self.alias = Alias.generate( self ) if self.alias.blank?
  end

end


class Alias < String

  def self.generate( user )
    suggestion = Alias.new user.last_name.downcase # mustermann
    suggestion = Alias.new user.first_name.downcase.first + "." + user.last_name.downcase if suggestion.taken? # m.mustermann
    suggestion = Alias.new user.first_name.downcase + "." + user.last_name.downcase if suggestion.taken? #max.mustermann
    # Wenn dies immernoch nicht ausreicht, wird das ganze zu einem Fehler führen, da der Alias weder leer noch bereits vorhanden sein darf.
    # Der Benutzer wird dann aufgefordert, einen anderen Alias zu wählen.
    return suggestion
  end

  def generate!( user )
    user.alias = Alias.generate( user )
  end

  def taken?
    User.find( :all, :conditions => "alias='#{self}'" ).size > 0
  end

end
