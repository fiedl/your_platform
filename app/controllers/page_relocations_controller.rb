class PageRelocationsController < ApplicationController

  expose :page
  expose :new_parent_page, -> { Page.find(params[:new_parent_page_id]) if params[:new_parent_page_id] }

  def new
    authorize! :manage, page

    set_current_title t :relocate_page
    set_current_navable page
    set_current_access :admin
  end

  def create
    authorize! :manage, page

    page.move_to new_parent_page
    page.delete_cache

    redirect_to page
  end

end