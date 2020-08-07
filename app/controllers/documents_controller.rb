class DocumentsController < ApplicationController

  expose :documents, -> {
    docs = current_user.documents_of_interest(limit: 50)
    docs = docs.tagged(params[:tags]) if params[:tags].present?
    docs
  }

  def index
    authorize! :index, :documents
    set_current_tab :documents
  end

  def new
    authorize! :create, Document

    set_current_title "Dokumente hochladen"
    set_current_tab :documents
  end

end