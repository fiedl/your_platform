class Pages::PublicGalleryPagesController < Pages::PublicPagesController

  expose :page, -> { Pages::PublicGalleryPage.find params[:id] }
  expose :images, -> { page.images }

  private

  def page_params
    params.require(:pages_public_gallery_page).permit(:title, :content)
  end

end