class Mobile::DocumentsController < ApplicationController

  def index
    authorize! :read, :mobile_documents

    @documents = current_user.documents_of_interest
      .select { |document| can? :read, document}

    set_current_title I18n.t :documents
  end

  def show
    @document = Attachment.find params[:id]
    authorize! :read, @document

    set_current_title @document.title
  end

end