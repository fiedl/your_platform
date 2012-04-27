# -*- coding: utf-8 -*-

require "user"

class UserPassword < UserPropertyString

  def encrypt
    encrypt_string self, salt
    #encrypt_string self, salt unless self.blank?
  end

  def encrypt!
    self.replace self.encrypt
  end

  def valid_against_encrypted_password?( encrypted_password, _salt )
    encrypted_password == encrypt_string( self, _salt )
  end

  def self.generate
    UserPassword.new( `pwgen -N 1 -n -c -B`.to_s[0..-2], :user => @user )
  end

  def generate!
    replace self.class.generate
  end

  def self.generate_salt( user )
    Digest::SHA1.hexdigest( "--#{Time.now}--#{user.name}--" )
  end

  def user
    @user
  end

  private

  def encrypt_string( string, _salt )
    if string and _salt
      return Digest::SHA1.hexdigest( "--#{_salt}--#{string}--" )
    else
      raise 'no string to encrypt given' unless string
      raise 'no salt given for encryption' unless _salt
    end
  end

  def salt
    return @user.account.salt if @user
  end

end


