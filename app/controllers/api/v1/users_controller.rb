class Api::V1::UsersController < Api::V1::BaseController

  # expose :users, -> { User.search(params[:query]) } #, limit: params[:limit].try(:to_i)) }
  #
  # api :GET, '/api/v1/search_users?query=Foo', "Lists all users that match the given query."
  # param :query, String, "Query string, e.g. user name"
  # param :limit, :number, "Limit the search results"
  #
  # def index
  #   authorize! :index, User
  #
  #   render json: users.as_json(methods: [:name, :title, :avatar_url])
  # end

  expose :user, -> { User.find(params[:id]) }

  api :GET, '/api/v1/users/ID', "Returns user with id ID."
  param :id, :number, "User id of the requested user"

  def show
    authorize! :read, user

    render json: user.as_json
  end

end