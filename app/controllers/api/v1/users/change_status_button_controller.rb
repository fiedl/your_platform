module Api::V1::Users
  class ChangeStatusButtonController < ApplicationController
    
    def show
      @user = User.find params[:user_id]
      authorize! :change_status, @user
      
      render html: render_partial('users/workflow_triggers', user: @user)
    end
    
  end
end