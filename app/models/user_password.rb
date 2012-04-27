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

  def valid_against_encrypted_password?( encrypted_password, salt )
    encrypted_password == encrypt_string( self, salt )
  end

  def self.generate
    Password.new( `pwgen -N 1 -n -c -B`.to_s[0..-2], :user => @user )
  end

  def generate!
    replace self.class.generate
  end

  private

  def encrypt_string( string, _salt )
    if string and _salt
      Digest::SHA1.hexdigest( "--#{_salt}--#{string}--" )
    end
  end

  def salt
    if @user
      @user.account.salt = new_salt unless @user.account.salt
      return @user.account.salt
    end
  end

  def new_salt
    Digest::SHA1.hexdigest( "--#{Time.now}--#{@user.name}--" )
  end

end


