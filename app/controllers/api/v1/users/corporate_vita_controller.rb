module Api::V1::Users
  class CorporateVitaController < ApplicationController
    
    def show
      @user = User.find params[:user_id]
      authorize! :read, @user
      
      render html: render_partial('users/corporate_vita', user: @user)
    end
    
  end
end