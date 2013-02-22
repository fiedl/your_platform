class AngularTestController < ApplicationController
  def index
    @user = User.find( params[ :user_id ] ) if params[ :user_id ]
    @user ||= @current_user
    @profile_fields = @user.profile_fields if @user
  end
end
