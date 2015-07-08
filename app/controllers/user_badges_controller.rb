class UserBadgesController < ApplicationController
  #load_and_authorize_resource class: 'Merit::Badge'
  skip_authorize_resource only: [:index, :show]
  
  def index
    if params[:user_id]
      @user = User.find params[:user_id]
      @badges = @user.badges
      authorize! :read, @user
      
      set_current_navable @user
      set_current_title "Badges - " + @user.title
    else
      @badges = Merit::Badge.all
      authorize! :index, Merit::Badge

      set_current_title "Badges"
    end
  end
  
  def show
    @badge = Merit::Badge.find params[:id].to_i
    
    authorize! :read, @badge
  end
  
end