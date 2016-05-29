class PageSettingsController < ApplicationController

  def index
    @page = Page.find params[:page_id]
    authorize! :manage, @page

    set_current_title @page.title
    set_current_navable @page
  end

end