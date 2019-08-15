# The app allows access to song texts, which are pages under
# the category flagged `:songs`.
#
class Api::V1::SongsController < Api::V1::BaseController

  expose :song, -> { page }
  expose :page, -> { Page.find(params[:id]) }

  expose :query, -> { params[:query] }

  expose :songs_parent, -> { Page.flagged(:songs).first }
  expose :songs, -> {
    pages = songs_parent.child_pages
    pages = pages.search_by_title(query) if query.present?
    pages = pages.visible_to(current_user)
    pages = pages.order(:title)
    pages
  }

  api :GET, '/api/v1/songs/ID', "Returns song page with id ID."
  param :id, :number, "Page id of the requested song"

  def show
    authorize! :read, song

    render json: song.as_json
  end

  api :GET, '/api/v1/songs', "Returns an array of song pages."
  api :GET, '/api/v1/songs?query=Foo', "Returns an array of songs matching the given query."
  param :query, String, "Query string to filter for certain songs."

  def index
    authorize! :read, songs_parent

    render json: songs.as_json(methods: [:body, :body_html])
  end

end