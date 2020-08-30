class Api::V1::Events::JoinController < Api::V1::BaseController

  expose :event

  def create
    authorize! :join, event

    current_user.join event
    render json: {}, status: :ok
  end

end