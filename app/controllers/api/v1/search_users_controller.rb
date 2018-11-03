class Api::V1::SearchUsersController < Api::V1::BaseController

  expose :users, -> { User.search(params[:query]) } #, limit: params[:limit].try(:to_i)) }

  api :GET, '/api/v1/search_users?query=Foo', "Lists all users that match the given query."
  param :query, String, "Query string, e.g. user name"
  param :limit, :number, "Limit the search results"

  def index
    authorize! :index, User

    render json: users.as_json(methods: [:name, :title, :avatar_url])
  end

end