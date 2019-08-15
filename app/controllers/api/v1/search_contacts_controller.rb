class Api::V1::SearchContactsController < Api::V1::BaseController

  api :GET, '/api/v1/search_contacts?query=Foo', "Lists all contacts (users, corporations) that match the given query."
  param :query, String, "Query string, e.g. user name"
  param :limit, :number, "Limit the search results"

  def index
    authorize! :index, User
    authorize! :index, Corporation

    @users = User.search(params[:query]) #, limit: params[:limit].try(:to_i))
    @users = @users.select { |user| (user.alive? && user.wingolfit?) || user.has_flag?(:dummy) }
    @users = @users.select { |user| can? :read, user }

    @corporations = Corporation.search(params[:query])
    @corporations = @corporations.select { |corporation| corporation.kind_of?(Corporation) && corporation.active? }
    @corporations = @corporations.select { |corporation| can? :read, corporation }

    render json: @corporations.as_json(methods: [:avatar_url, :title, :type]) +
        @users.as_json(methods: [:name, :title, :avatar_url])
  end

end