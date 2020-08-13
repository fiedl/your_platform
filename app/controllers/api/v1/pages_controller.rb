class Api::V1::PagesController < Api::V1::BaseController

  expose :page

  def update
    authorize! :update, page
    page.update! page_params
    render json: page, status: :ok
  end

  def destroy
    authorize! :destroy, page
    page.descendant_pages.each(&:destroy!) if page.kind_of? Pages::PublicPage
    page.destroy!
    render json: {}, status: :ok
  end

  expose :parent_page, -> { Page.find params[:parent_page_id] if params[:parent_page_id].present? }

  def create
    raise "No parent page given" unless parent_page.present?
    authorize! :update, parent_page

    new_page = parent_page.child_pages.create page_params.merge({type: parent_page.type})

    render json: new_page.as_json.merge({
      path: polymorphic_path(new_page)
    }), status: :ok
  end

  private

  def page_params
    params.require(:page).permit(:title, :content, :image)
  end

end