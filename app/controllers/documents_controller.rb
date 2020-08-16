class DocumentsController < ApplicationController

  expose :page, -> { Page.find params[:page_id] if params[:page_id].present? }
  expose :page_breadcrumbs, -> {
    page.ancestor_pages.regular + [page]
  }
  expose :group, -> { Group.find params[:group_id] if params[:group_id].present? }
  expose :user, -> { User.find params[:user_id] if params[:user_id].present? }
  expose :tags, -> { params[:tags] }
  expose :all, -> { params[:all] }

  expose :documents, -> {
    docs = current_user.documents_in_my_scope.includes(:author)
    docs = docs.where(parent_type: "Page", parent_id: [page.id] + page.descendant_page_ids) if page
    docs = docs.where(author_user_id: user.id) if user
    docs = docs.where(parent_type: "Page", parent_id: group.descendant_pages).or(
      docs.where(parent_type: "Post", parent_id: group.descendant_posts)
    ).or(
      docs.where(parent_type: "Post", parent_id: group.posts)
    ) if group
    docs = docs.by_categories(tags) if tags.present?
    docs = docs.order(created_at: :desc)
    docs = docs.limit(50) unless page || group || tags || all
    docs = docs.select { |doc| can? :read, doc }
    docs = docs
  }

  def index
    authorize! :index, :documents
    set_current_tab :documents
    set_current_title t :documents
    set_current_title params[:tags].join(" | ") if params[:tags].present?
  end

  expose :drafted_post, -> { current_user.drafted_posts.where(sent_via: post_draft_via_key).order(created_at: :desc).first_or_create }
  expose :post_draft_via_key, -> { "documents-new" }

  def new
    authorize! :create, Document

    set_current_title "Dokumente hochladen"
    set_current_tab :documents
  end

end