class Api::V1::DocumentsController < Api::V1::BaseController

  expose :documents, -> {
    docs = current_user.documents_in_my_scope
    docs = docs.where("title like ?", "%#{query}%") if query
    docs = docs.limit(limit) if limit
    docs = docs.order(created_at: :desc)
    docs
  }
  expose :limit, -> { params[:limit] }
  expose :query, -> { params[:query] }

  api :GET, '/api/v1/documents/ID', "Returns the document with the id ID."
  param :id, :number, "Document id of the requested document"

  def show
    authorize! :read, document

    render json: document.as_json
  end


  api :GET, '/api/v1/documents', "Returns documents in the scope of the current user."
  api :GET, '/api/v1/documents?query=Foo', "Returns an array of documents matching the given query."
  param :query, String, "Query string to filter for certain documents."

  def index
    authorize! :index, Attachment

    render json: documents.as_json(methods: [:thumb_url, :file_url, :scope_title])
  end

end