class Api::V1::SearchPagesController < Api::V1::BaseController

  expose :pages, -> { Page.search(params[:query], limit: params[:limit].try(:to_i)) }

  api :GET, '/api/v1/page_search?query=Foo', "Lists all pages that match the given query."
  param :query, String, "Query string, e.g. page title"
  param :limit, :number, "Limit the search results"

  def index
    authorize! :index, Page

    render json: pages.as_json(methods: [:breadcrumb_titles])
  end

end