class Api::V1::Events::LeaveController < Api::V1::BaseController

  expose :event

  def create
    authorize! :leave, event

    current_user.leave event
    render json: {}, status: :ok
  end

end