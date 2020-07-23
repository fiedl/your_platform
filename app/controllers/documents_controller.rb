class DocumentsController < ApplicationController

  expose :documents, -> { current_user.documents_of_interest }

  def index
    authorize! :index, :documents
  end

  def new
    authorize! :create, Document

    set_current_title "Dokumente hochladen"
    set_current_tab :documents
  end

end