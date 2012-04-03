class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(:first, :conditions => "alias = #{:alias}")
    @profile_fields = @user.profile_fields
    @title = @user.name
  end

    
end
