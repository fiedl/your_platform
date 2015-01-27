class UserSettingsController < ApplicationController
  
  skip_authorization_check only: [:index]
  
  def index
    authorize! :update, @user
    
    @user = User.find(params[:user_id])
    @navable = @user
  end
  
end