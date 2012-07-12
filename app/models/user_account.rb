# -*- coding: utf-8 -*-
class UserAccount < ActiveRecord::Base

  has_secure_password      # This provides a `password` attribute to set a new password. 
                           # The encrypted password is saved in the `password_digest` column.
                           # See: * http://railscasts.com/episodes/270-authentication-in-rails-3-1
                           #      * http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html

  belongs_to               :user, inverse_of: :account

  before_validation        :generate_password_if_unset  # This needs to run before validation, since validation
                                                        # requires a password to be set in order to allow saving the account.
                                                        # See ressources of `has_secure_password` above. 

  after_save               :send_welcome_email_if_just_created


  # Tries to identify a user based on the given `login_string` and to authenticate this user 
  # with the given `password`. 
  def self.authenticate( login_string, password )
    identified_user = UserAccount.identify_user_with_account( login_string )
    if identified_user
      if identified_user.account.authenticate( password )
        authenticated_user = identified_user
      else  
        raise 'wrong_password'
      end
    end
    return authenticated_user
  end

  # Tries to identify a user based on the given `login_string`.
  def self.identify_user_with_account( login_string )

    # What can go wrong?
    # 1. No user could match the login string.
    users_that_match_the_login_string = UserIdentification.find_users( login_string )
    raise 'no_user_found' unless users_that_match_the_login_string.count > 0
    
    # 2. The user may not have an active user account.
    users_that_match_the_login_string_and_have_an_account = users_that_match_the_login_string.find_all do |user|
      user.has_account? 
    end
    raise 'user_has_no_account' unless users_that_match_the_login_string_and_have_an_account.count > 0
    
    # 3. The identification string may refer to several users with an active user account.
    raise 'identification_not_unique' if users_that_match_the_login_string_and_have_an_account.count > 1
    identified_user = users_that_match_the_login_string_and_have_an_account.first

    return identified_user
  end


  def generate_password
    self.password = Password.generate
  end

  # This generates a password if (1) no password is stored in the database
  # and (2) no new password is set to be saved (in the `password` attribute).
  def generate_password_if_unset
    unless self.password_digest
      unless self.password
        self.generate_password
      end
    end
  end      
    
  # This sends a welcome email to the user of the newly created user account.
  def send_welcome_email_if_just_created
    if id_changed? # If the id of the record has changed, this is a new record.
      UserAccountMailer.welcome_email( self.user, self.password ).deliver
    end
  end  

end
