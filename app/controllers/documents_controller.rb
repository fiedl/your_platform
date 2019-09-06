class DocumentsController < ApplicationController

  expose :documents, -> { current_user.documents_of_interest }

  def index
    authorize! :index, :documents
  end

end