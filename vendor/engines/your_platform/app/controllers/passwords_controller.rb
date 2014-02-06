class PasswordsController < Devise::PasswordsController
  
  def new
    super
  end
  
  # This method overrides the original one by devise:
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/passwords_controller.rb
  #
  # We do not allow custom passwords at the moment. 
  # So, this method redirects to the action that generates a new password
  # and sends this new password via email.
  #
  def create
    redirect_to sign_in_path, notice: 'This is a test. This action does nothing at the moment.'
  end
  
  def edit
    super
  end

  def update
    redirect_to sign_in_path, notice: 'This is a test. This action does nothing at the moment.'
  end
  
end