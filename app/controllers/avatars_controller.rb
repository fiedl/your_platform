class AvatarsController < ApplicationController
  skip_authorization_check only: :show

  # This is an api to redirect to the avatar image of a user
  # that is identified by email.
  #
  # For example:
  #
  #     http://localhost:3000/avatars?email=doe@example.com&size=64
  #
  # Or, for use in the api:
  #
  #     GET /api/v1/users/123/avatar
  #
  def show
    authorize! :read, :avatars

    @user = User.find_by_email(params[:email]) if params[:email]
    @user ||= User.find params[:user_id] if params[:user_id]
    @size = params[:size]

    if @user
      redirect_to view_context.user_avatar_url(@user, size: @size)
    else
      redirect_to view_context.user_avatar_default_url
    end
  end

end