#
# Every User may have an UserAccount that enables the user to log in to the website.
# 
#    user = User.create(...)       # This user may not log in.
#    account = user.build_account
#    account.password = "foo"
#    account.save                  # Now, the user may log in.
#    account.destroy               # Now, the user may not log in anymore. 
#
class UserAccount < ActiveRecord::Base
  
  # For authentication, we use devise, 
  # https://github.com/plataformatec/devise.
  # 
  # Available Modules:
  #   Database Authenticatable: 
  #     encrypts and stores a password in the database to validate the authenticity of a user
  #     while signing in. The authentication can be done both through POST requests or 
  #     HTTP Basic Authentication.
  #   Omniauthable: adds Omniauth (https://github.com/intridea/omniauth) support;
  #   Confirmable: sends emails with confirmation instructions and verifies whether an account
  #     is already confirmed during sign in.
  #   Recoverable: resets the user password and sends reset instructions.
  #   Registerable: handles signing up users through a registration process, also allowing 
  #     them to edit and destroy their account.
  #   Rememberable: manages generating and clearing a token for remembering the user from a 
  #     saved cookie.
  #   Trackable: tracks sign in count, timestamps and IP address.
  #   Timeoutable: expires sessions that have no activity in a specified period of time.
  #   Validatable: provides validations of email and password. It's optional and can be customized, 
  #     so you're able to define your own validations.
  #   Lockable: locks an account after a specified number of failed sign-in attempts. 
  #     Can unlock via email or after a specified time period.
  # 
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
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

  delegate :email, :to => :user, :allow_nil => true

  # HACK: This method seems to be required by the PasswordController and is missing, 
  # since we have a virtual email field. 
  # TODO: If we ever change the Password authentication 
  # field to login, remove this method.
  #
  def email_changed?
    false
  end
  
  # Configure each account to *not* automatically log out when the browser is closed.
  # After a system reboot, the user is still logged in, which is the expected behaviour
  # for this application.
  #
  # This useses devise's rememberable module.
  #
  def remember_me
    true
  end

  # Used by devise to identify the correct user account by the given strings.
  #
  def self.find_first_by_auth_conditions(warden_conditions)
    login_string = warden_conditions[:login] || warden_conditions[:email]
    return UserAccount.identify(login_string) if login_string
    return UserAccount.where(warden_conditions).first # use devise identification system for auth tokens and the like.
  end

  # Tries to identify a user based on the given `login_string`.
  # This can be one of those defined in `User.attributes_used_for_identification`,
  # currently, `[:alias, :last_name, :name, :email]`.
  #
  # Bug fix: The alias is prioritized, such that a user having the alias *doe*
  # can be identified by this alias even if there are other users with surname *Doe*.
  #
  def self.identify(login_string)
    
    # Priorization: Check alias first. (Bug fix)
    user_identified_by_alias = User.find_by_alias(login_string)
    users_that_match_the_login_string = [ User.find_by_alias(login_string) ] if user_identified_by_alias
    
    # What can go wrong?
    # 1. No user could match the login string.
    users_that_match_the_login_string ||= User.find_all_by_identification_string(login_string)
    raise 'no_user_found' unless users_that_match_the_login_string.count > 0
    
    # 2. The user may not have an active user account.
    users_that_match_the_login_string_and_have_an_account = users_that_match_the_login_string.select do |user|
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
  
  def auth_token
    super || generate_auth_token!
  end
  
  def generate_auth_token!
    # see also: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    #
    raise 'auth_token already set' if self.read_attribute(:auth_token)
    token = ''
    loop do
      token = Devise.friendly_token + Devise.friendly_token
      break token unless UserAccount.where(auth_token: token).first
    end
    self.update_attribute :auth_token, token
  end

  def send_welcome_email
    raise 'attempt to send welcome email with empty password' unless self.password
    UserAccountMailer.welcome_email( self.user, self.password ).deliver
  end
    
  
  # This overrides the devise method that would assign a newly entered password.
  # But: We do not support custom passwords, currently. Thus, this method actually
  # sends a password via email.
  # 
  # FIXME: This should not happen here in the model. The method name does not suggest
  # that an email is sent by it. 
  #
  # For now, this dirty hack is used, because it's quite hard to override the devise
  # controller in this manner.
  #
  # This `update` action will trigger the reset:
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/passwords_controller.rb#L30
  #
  # This is how one would override a devise controller:
  # http://stackoverflow.com/questions/3546289/override-devise-registrations-controller
  #
  # Make sure the views are moved from views/devise/passwords/... to views/passwords/... .
  #
  # The `reset_password_by_token` method shows how to find the matching user account, here
  # named as `recoverable`:
  # https://github.com/plataformatec/devise/blob/d75fd56f150f006aee51dcafc7157454190de570/lib/devise/models/recoverable.rb#L109
  #
  def reset_password!(new_password, new_password_confirmed)
    send_new_password
  end
  

end
