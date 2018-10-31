class Api::V1::CurrentUserController < Api::V1::BaseController

  expose :groups, -> { Group.search(params[:query], limit: params[:limit].try(:to_i)) }

  api :GET, '/api/v1/current_user', "Returns information about the currently signed-in user."

  skip_authorization_check only: [:show]

  def show
    render json: current_user.as_json
  end

end