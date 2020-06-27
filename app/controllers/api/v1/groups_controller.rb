class Api::V1::GroupsController < Api::V1::BaseController

  expose :group, -> { Group.find(params[:id]) }

  api :GET, '/api/v1/groups/ID', "Returns group with id ID."
  param :id, :number, "Group id of the requested group"

  def show
    authorize! :read, group

    render json: group.as_json(methods: [:title, :avatar_url, :profile_fields, :important_officers])
  end

end