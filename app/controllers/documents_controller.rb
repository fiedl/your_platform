class DocumentsController < ApplicationController

  expose :documents, -> {
    docs = current_user.documents_of_interest(limit: 50)
    # docs = docs.tagged(params[:tags]) if params[:tags].present?
    docs = docs.by_categories(params[:tags]) if params[:tags].present?
    docs = docs.select { |doc| can? :read, doc }
    docs = docs.sort_by { |doc| - doc.created_at.to_i }
    docs = docs
  }

  def index
    authorize! :index, :documents
    set_current_tab :documents
    set_current_title t :documents
    set_current_title params[:tags].join(" & ") if params[:tags].present?
  end

  expose :drafted_post, -> { current_user.drafted_posts.where(sent_via: post_draft_via_key).order(created_at: :desc).first_or_create }
  expose :post_draft_via_key, -> { "documents-new" }

  def new
    authorize! :create, Document

    set_current_title "Dokumente hochladen"
    set_current_tab :documents
  end

end