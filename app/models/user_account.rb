# -*- coding: utf-8 -*-
class UserAccount < ActiveRecord::Base
  
  attr_accessible :encrypted_password
  
#  validates_presence_of    :salt, :encrypted_password

  belongs_to               :user, inverse_of: :user_account

  attr_accessor            :new_password

  before_save              :ensure_salt_exists, :encrypt_new_password_if_necessary

  # Gibt das Benutzerobjekt zurück, dass zum Login-String und dem angegebenen Passwort passt. 
  # Wenn etwa zwei Benutzer den gleichen Nachnamen haben, dient also das Passwort der Identifizierung.
  # TODO: ACHTUNG: Ist das eine Sicherheitslücke? Wenn nämlich zwei Benutzer gleichen Nachnamens das gleiche Passwort haben, kann 
  # es passieren, dass man als der falsche Benutzer Zugang erhält. 
  def self.authenticate( login_string, password )
    users = UserIdentification.find_users( login_string )
    authenticated_user = nil
    if users
      users.each do |user| 
        if user.has_account?
          if user_password_correct? user, password
            authenticated_user = user 
          else
            raise 'wrong_password'
          end
        else
          raise 'user_has_no_account'
        end
      end
    else
      raise 'no_user_found'
    end
    if authenticated_user
      return authenticated_user
    end
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
    UserAccountMailer.welcome_email( self.user, self.new_password ).deliver
  end

  private

  def self.user_password_correct?( user, password )
    account = user.account
    UserPassword.new( password ).valid_against_encrypted_password?( account.encrypted_password, account.salt )
  end

  # Stellt sicher, dass der Salt für den Benutzer nicht leer ist. Sonst kann das Passwort nicht sicher gespeichert werden.
  def ensure_salt_exists
    self.salt = UserPassword.generate_salt( self.user ) unless self.salt
  end

  # Verschlüsselt das neue Passwort, sofern ein neues Passwort gesetzt ist. Wenn keines gesetzt ist, wird auch der verschlüsselte
  # String leer bleiben.
  def encrypt_new_password_if_necessary
    ensure_salt_exists
    self.encrypted_password = self.new_password.encrypt unless self.new_password.blank?
  end

end
