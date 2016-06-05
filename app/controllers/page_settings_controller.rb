class PageSettingsController < ApplicationController

  def index
    @page = Page.find params[:page_id]
    authorize! :manage, @page

    set_current_title @page.title
    set_current_navable @page
    set_current_access :admin
    set_current_access_text :only_page_admins_can_view_or_change_these_settings
  end

end