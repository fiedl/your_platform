class UserSettingsController < ApplicationController
  
  skip_authorization_check only: [:index, :show, :update]

  # /settings  
  def index
    authorize! :update, user
    
    @user = user
    
    set_current_navable @user
    set_current_title t(:user_settings)
    set_current_activity :is_managing_user_settings
    
    render action: 'show'
  end

  # /users/123/settings
  def show
    @user = user
    authorize! :update, user
    
    set_current_navable @user
    set_current_title t(:user_settings)
    set_current_activity :is_managing_user_settings
  end
  
  def update
    @user = user
    authorize! :update, @user
    
    if not user_params[:incognito].nil?
      if user_params[:incognito] == true
        current_user.update_last_seen_activity nil
      end
      
      if user_params[:incognito] == 'true'
        @user.incognito = true
      elsif user_params[:incognito] == 'false'
        @user.incognito = false
      end
      @user.save
    end

    render nothing: true
  end
  

private

  def user
    params[:user_id] ? User.find(params[:user_id]) : current_user
  end
    
  def user_params
    params.require(:user).permit(:incognito)
  end
  
end