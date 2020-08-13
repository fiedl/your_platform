class Pages::PublicEventsPagesController < Pages::PublicPagesController

  expose :page, -> { Pages::PublicEventsPage.find params[:id] }
  expose :group, -> { page.root.group }
  expose :semester_calendar, -> { page.semester_calendar! }

  private

  def page_params
    params.require(:pages_public_events_page).permit(:title, :content, :image)
  end

end