class Api::V1::SearchUsersController < Api::V1::BaseController

  api :GET, '/api/v1/search_users?query=Foo', "Lists all users that match the given query."
  param :query, String, "Query string, e.g. user name"
  param :find_non_wingolf_users, :bool, "Whether to find non-wingolf members as well"
  param :find_deceased_users, :bool, "Whether to find deceased useres"

  def index
    authorize! :index, User

    @users = search_base.accessible_by(current_ability, :index).search(params[:query])

    render json: @users.as_json(methods: [:name, :title, :name_affix, :avatar_path, :search_hint])
  end

  private

  def search_base
    base = User
    base = base.alive unless params[:find_deceased_users].to_boolean
    base = base.wingolfiten unless params[:find_non_wingolf_users].to_boolean
    base
  end

end