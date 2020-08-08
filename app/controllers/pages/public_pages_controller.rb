class Pages::PublicPagesController < ApplicationController

  expose :page, -> { Pages::PublicPage.find params[:id] }
  expose :group, -> { page.root.group }

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