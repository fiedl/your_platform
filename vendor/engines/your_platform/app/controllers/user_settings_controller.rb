class UserSettingsController < ApplicationController
  
  skip_authorization_check only: [:index, :show]

  # /settings  
  def index
    authorize! :update, current_user
    
    @user = current_user
    @navable = @user
    
    current_user.update_last_seen_activity "nimmt Benutzereinstellungen vor"
    
    render action: 'show'
  end

  # /users/123/settings
  def show
    authorize! :update, @user
    
    @user = User.find(params[:user_id])
    @navable = @user
    
    current_user.update_last_seen_activity "nimmt Benutzereinstellungen vor"
  end
end