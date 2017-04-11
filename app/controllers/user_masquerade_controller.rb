class UserMasqueradeController < ApplicationController

  expose :user

  # GET /users/123/sign_in
  def show
    authorize! :use, :masquerade
    authorize! :masquerade_as, user

    if account = user.account
      redirect_to masquerade_path(account)
    else
      raise "user #{user.id} has no account."
    end
  end

end