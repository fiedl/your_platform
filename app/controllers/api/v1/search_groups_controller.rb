class Api::V1::SearchGroupsController < ApplicationController

  expose :groups, -> { Group.search params[:query], limit: 10, current_user: current_user }
  expose :required_ability, -> { params[:required_ability] || :index }

  api :GET, '/api/v1/group_search?query=Foo', "Lists all groups that match the given query."
  param :query, String, "Query string, e.g. group name"
  param :limit, :number, "Limit the search results"

  def index
    authorize! :index, Group

    render json: groups.select { |group| can? :create_post, group }.as_json(methods: [:title, :avatar_path, :corporation]), status: :ok
  end

end