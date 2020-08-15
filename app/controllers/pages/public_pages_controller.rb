class Pages::PublicPagesController < ApplicationController

  expose :page, -> { Pages::PublicPage.find params[:id] }
  expose :group, -> { page.root.group }

  expose :posts, -> { page.posts.published.public_post.order(published_at: :desc).accessible_by(current_ability).limit(10) }
  expose :drafted_post, -> { current_user.drafted_posts.where(sent_via: post_draft_via_key).last }
  expose :post_draft_via_key, -> { "page-#{page.id}" }

  def show
    authorize! :read, page

    set_current_navable page
    set_current_title page.title
  end

  def update
    authorize! :update, page

    page.update! page_params
    render json: page, status: :ok
  end

  private

  def page_params
    params.require(:pages_public_page).permit(:title, :content, :image)
  end

end