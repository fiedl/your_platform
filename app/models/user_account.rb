# -*- coding: utf-8 -*-
class UserAccount < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to       :user

  attr_accessor    :new_password

  before_save      :encrypt_new_password_if_necessary

  # Gibt das Benutzerobjekt zurück, dass zum Login-String und dem angegebenen Passwort passt. 
  # Wenn etwa zwei Benutzer den gleichen Nachnamen haben, dient also das Passwort der Identifizierung.
  # TODO: ACHTUNG: Ist das eine Sicherheitslücke? Wenn nämlich zwei Benutzer gleichen Nachnamens das gleiche Passwort haben, kann 
  # es passieren, dass man als der falsche Benutzer Zugang erhält. 
  def self.authenticate( login_string, password )
    users = UserIdentification.find_users( login_string )
    authenticated_user = nil
    if users
      users.each do |user| 
        authenticated_user = user if user_password_correct? user, password
      end
    end
    return authenticated_user
  end

  def authenticate( password )
    user_password_correct? self.user, password 
  end

  def new_password
    require "user_password"
    @new_password = "" unless @new_password
    @new_password = UserPassword.new( @new_password, :user => self.user ) unless @new_password.kind_of? UserPassword
    return @new_password
  end    

  def generate
    self.new_password.generate!
    puts "EMAIL...."
    
  end

  private

  def self.user_password_correct?( user, password )
    account = user.account
    UserPassword.new( password ).valid_against_encrypted_password( account.encrypted_password, account.salt )
  end

  def encrypt_new_password_if_necessary
    # Nur wenn ein neues Passwort gesetzt wird, wird es verschlüsselt gespeichert.
    self.encrypted_password = new_password.encrypt unless new_password.blank?
  end

end
