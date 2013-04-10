# -*- coding: utf-8 -*-
class UserAccount < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable, :registerable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me

  # Virtual attribute for authenticating by either username, alias or email
  attr_accessor :login

  belongs_to               :user, inverse_of: :account

  before_validation        :generate_password_if_unset
                             # This needs to run before validation, since validation
                             # requires a password to be set in order to allow saving the account.
                             # See ressources of `has_secure_password` above. 

  before_save              :generate_password_if_unset
                             # This is required, because, apparently, the `before_validation` callback is not called
                             # if the account is created via an association (like User.create( ... , create_account: true )).
                             # But `before_save` callbacks are called.
                             # Notice: Apparently, even `validates_associated :account` in the User model has no effect.

  after_save               :send_welcome_email_if_just_created

  def email
    user.email if user
  end

  #HACK: This method seems to be required by the PasswordController and is missing, since we have a virtual email
  #field. If we ever change the Password authentication field to login, remove this method.
  def email_changed?
    false
  end

  # Used by devise to identify the correct user account by the given strings
  def self.find_first_by_auth_conditions(warden_conditions)
    login = warden_conditions[:login] || warden_conditions[:email]
    return self.identify_user_account(login) if login # user our own identification system for virtual attributes
    where(warden_conditions).first # use devise identification system for auth tokens and the like.
  end


  # Tries to identify a user based on the given `login_string`.
  def self.identify_user_account( login_string )

    # What can go wrong?
    # 1. No user could match the login string.
    users_that_match_the_login_string = User.find_all_by_identification_string( login_string )
    raise 'no_user_found' unless users_that_match_the_login_string.count > 0
    
    # 2. The user may not have an active user account.
    users_that_match_the_login_string_and_have_an_account = users_that_match_the_login_string.find_all do |user|
      user.has_account? 
    end
    raise 'user_has_no_account' unless users_that_match_the_login_string_and_have_an_account.count > 0
    
    # 3. The identification string may refer to several users with an active user account.
    raise 'identification_not_unique' if users_that_match_the_login_string_and_have_an_account.count > 1
    identified_user = users_that_match_the_login_string_and_have_an_account.first

    return identified_user.account
  end

  def send_new_password
    generate_password
    self.save
    send_welcome_email
  end

  def generate_password
    self.password = Password.generate
  end

  # This generates a password if (1) no password is stored in the database
  # and (2) no new password is set to be saved (in the `password` attribute).
  def generate_password_if_unset
    if self.encrypted_password.blank?
      unless self.password
        self.generate_password
      end
    end
  end      

  def send_welcome_email
    raise 'attempt to send welcome email with empty password' unless self.password
    UserAccountMailer.welcome_email( self.user, self.password ).deliver
  end
    
  # This sends a welcome email to the user of the newly created user account.
  def send_welcome_email_if_just_created
    if id_changed? # If the id of the record has changed, this is a new record.
      send_welcome_email
    end
  end  

end
